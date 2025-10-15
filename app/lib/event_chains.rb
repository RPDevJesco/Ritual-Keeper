# frozen_string_literal: true

# EventChains Design Pattern Implementation
# Lightweight version optimized for DragonRuby GTK

# ==================== Event Context ====================

class EventContext
  def initialize
    @data = {}
  end

  def []=(key, value)
    @data[key] = value
  end

  def [](key)
    @data[key]
  end

  def key?(key)
    @data.key?(key)
  end

  def fetch(key, default = nil)
    @data.fetch(key, default)
  end

  def to_h
    @data.dup
  end

  def clear!
    @data.clear
  end
end

# ==================== Event Result ====================

class EventResult
  attr_reader :data, :error, :error_message

  def initialize(success, data = nil, error = nil, error_message = nil)
    @success = success
    @data = data
    @error = error
    @error_message = error_message
  end

  def self.success(data)
    new(true, data, nil, nil)
  end

  def self.failure(error)
    message = error.is_a?(String) ? error : error.message
    error_obj = error.is_a?(Exception) ? error : nil
    new(false, nil, error_obj, message)
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end

# ==================== Chain Result ====================

class ChainResult
  class EventFailure
    attr_reader :event_name, :error_message

    def initialize(event_name, error)
      @event_name = event_name
      @error_message = error.is_a?(String) ? error : error&.message
    end
  end

  attr_reader :data, :failures

  def initialize(success, data, failures = [])
    @success = success
    @data = data
    @failures = failures
  end

  def self.success(data)
    new(true, data, [])
  end

  def self.partial_success(data, failures)
    new(true, data, failures)
  end

  def self.failure(data, failures)
    new(false, data, failures)
  end

  def success?
    @success
  end

  def failure?
    !@success
  end

  def has_failures?
    !@failures.empty?
  end

  def failure_count
    @failures.length
  end
end

# ==================== Fault Tolerance ====================

module FaultTolerance
  module Mode
    STRICT = :strict
    LENIENT = :lenient
    BEST_EFFORT = :best_effort
    CUSTOM = :custom
  end

  class Config
    attr_reader :mode
    attr_accessor :should_continue_proc, :on_failure_proc

    def initialize(mode = Mode::STRICT)
      @mode = mode
      @should_continue_proc = nil
      @on_failure_proc = nil
    end

    def should_continue?(event, error)
      case @mode
      when Mode::STRICT
        false
      when Mode::LENIENT, Mode::BEST_EFFORT
        true
      when Mode::CUSTOM
        @should_continue_proc&.call(event, error) || false
      else
        false
      end
    end

    def handle_failure(event, error)
      @on_failure_proc&.call(event, error)
    end
  end
end

# ==================== Chainable Event ====================

module ChainableEvent
  def execute(context)
    raise NotImplementedError, "#{self.class} must implement execute(context)"
  end

  def success(context)
    EventResult.success(context)
  end

  def failure(error_message)
    EventResult.failure(error_message)
  end

  def validate_context!(context, *required_keys)
    missing = required_keys.reject { |key| context.key?(key) }
    
    unless missing.empty?
      raise ArgumentError, "#{self.class.name} requires context keys: #{missing.join(', ')}"
    end
  end
end

# ==================== Event Chain ====================

class EventChain
  attr_reader :context, :fault_tolerance

  def initialize(fault_tolerance_mode = FaultTolerance::Mode::STRICT)
    @events = []
    @middlewares = []
    @context = EventContext.new
    @fault_tolerance = FaultTolerance::Config.new(fault_tolerance_mode)
    @failures = []
  end

  def add_event(event)
    @events << event
    self
  end

  def use_middleware(&middleware)
    @middlewares << middleware
    self
  end

  def on_failure(&block)
    @fault_tolerance.on_failure_proc = block
    self
  end

  def should_continue(&block)
    @fault_tolerance.should_continue_proc = block
    self
  end

  def execute
    @failures = []
    
    # Build middleware pipeline (LIFO)
    pipeline = ->(evt, ctx) { evt.execute(ctx) }
    
    @middlewares.reverse_each do |middleware|
      pipeline = middleware.call(pipeline)
    end

    # Execute each event through pipeline
    @events.each do |event|
      result = execute_event_with_pipeline(event, pipeline)
      
      unless result.success?
        failure = ChainResult::EventFailure.new(event.class.name, result.error_message || result.error)
        @failures << failure
        
        @fault_tolerance.handle_failure(event, result.error_message || result.error)
        
        unless @fault_tolerance.should_continue?(event, result.error_message || result.error)
          return ChainResult.failure(@context, @failures)
        end
      end
    end

    if @failures.empty?
      ChainResult.success(@context)
    else
      ChainResult.partial_success(@context, @failures)
    end
  end

  def self.strict
    new(FaultTolerance::Mode::STRICT)
  end

  def self.lenient
    new(FaultTolerance::Mode::LENIENT)
  end

  def self.best_effort
    new(FaultTolerance::Mode::BEST_EFFORT)
  end

  def self.custom
    new(FaultTolerance::Mode::CUSTOM)
  end

  private

  def execute_event_with_pipeline(event, pipeline)
    begin
      result = pipeline.call(event, @context)
      
      unless result.is_a?(EventResult)
        EventResult.success(@context)
      else
        result
      end
    rescue StandardError => e
      EventResult.failure(e)
    end
  end
end

# ==================== Middleware ====================

module Middleware
  class Timing
    def initialize(threshold_ms: nil)
      @threshold_ms = threshold_ms
    end

    def call(next_step)
      ->(evt, ctx) do
        start_time = Time.now
        result = next_step.call(evt, ctx)
        elapsed = ((Time.now - start_time) * 1000).round(2)
        
        if @threshold_ms && elapsed > @threshold_ms
          puts "⚠️  #{evt.class.name} took #{elapsed}ms (threshold: #{@threshold_ms}ms)"
        end
        
        result
      end
    end
  end

  class Metrics
    attr_reader :metrics

    def initialize
      @metrics = {
        total_events: 0,
        successful_events: 0,
        failed_events: 0,
        total_duration_ms: 0
      }
    end

    def call(next_step)
      ->(evt, ctx) do
        @metrics[:total_events] += 1
        
        start_time = Time.now
        result = next_step.call(evt, ctx)
        duration = ((Time.now - start_time) * 1000).round(2)
        
        @metrics[:total_duration_ms] += duration
        
        if result.success?
          @metrics[:successful_events] += 1
        else
          @metrics[:failed_events] += 1
        end
        
        result
      end
    end

    def report
      puts "\n" + "=" * 50
      puts "Chain Metrics"
      puts "=" * 50
      puts "Total Events: #{@metrics[:total_events]}"
      puts "Successful: #{@metrics[:successful_events]}"
      puts "Failed: #{@metrics[:failed_events]}"
      puts "Total Duration: #{@metrics[:total_duration_ms].round(2)}ms"
      avg = @metrics[:total_events] > 0 ? (@metrics[:total_duration_ms] / @metrics[:total_events]).round(2) : 0
      puts "Average Duration: #{avg}ms"
      puts "=" * 50 + "\n"
    end
  end
end
