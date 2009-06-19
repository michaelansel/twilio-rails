module Twilio
  module Verb
    module ClassMethods
      @attributes = []
      @allowed_verbs = []
      attr_accessor :attributes

      def allowed_verbs(*verbs)
        return @allowed_verbs if verbs == []
        @allowed_verbs = [] if @allowed_verbs.nil?
        verbs.each do |verb|
          @allowed_verbs << verb.to_s.capitalize
        end
        @allowed_verbs = @allowed_verbs.uniq
      end

      def attributes(*attrs)
        return @attributes if attrs == []
        @attributes = [] if @attributes.nil?
        @attributes = (@attributes + attrs).uniq
        attr_accessor(*@attributes)
        @attributes
      end
    end

    def attributes
      self.class.attributes
    end

    def allowed?(verb)
      self.class.allowed_verbs.nil? ? false : self.class.allowed_verbs.include?(verb.to_s.capitalize)
    end

    def initialize(body = nil, params = {})
      @children = []
      if body.class == String
        @body = body
      else
        @body = nil
        params = body || {}
      end
      params.each do |k,v|
        send(k.to_s+"=",v) if respond_to? k.to_s+"="
      end
    end

    def to_xml(opts = {})
      require 'builder' unless defined?(Builder)
      opts[:builder]  ||= Builder::XmlMarkup.new(:indent => opts[:indent])

      b = opts[:builder]
      attrs = {}
      attributes.each {|a| attrs[a] = send(a) unless send(a).nil? } unless attributes.nil?

      if @children and @body.nil?
        b.__send__(self.class.to_s.split(/::/)[-1], attrs) do
          @children.each {|e|e.to_xml( opts.merge(:skip_instruct => true) )}
        end
      elsif @body and @children == []
        b.__send__(self.class.to_s.split(/::/)[-1], @body)
      else
        raise ArgumentError, "Cannot have children and a body at the same time"
      end
    end


    ##### Verb Convenience Methods #####
    def say(string_to_say, opts = {})
      return unless allowed? :say
      @children << Twilio::Say.new(string_to_say, opts)
      @children[-1]
    end

    def play(file_to_play, opts = {})
      return unless allowed? :play
      @children << Twilio::Play.new(file_to_play, opts)
      @children[-1]
    end

    def gather(opts = {})
      return unless allowed? :gather
      @children << Twilio::Gather.new(opts)
      @children[-1]
    end

    def record(opts = {})
      return unless allowed? :record
      @children << Twilio::Record.new(opts)
      @children[-1]
    end

    def dial(number = "", opts = {})
      return unless allowed? :dial
      @children << Twilio::Dial.new(number, opts)
      @children[-1]
    end

    def redirect(url, opts = {})
      return unless allowed? :redirect
      @children << Twilio::Redirect.new(url, opts)
      @children[-1]
    end

    def pause(opts = {})
      return unless allowed? :pause
      @children << Twilio::Pause.new(opts)
      @children[-1]
    end

    def hangup
      return unless allowed? :hangup
      @children << Twilio::Hangup.new
      @children[-1]
    end

    def number(number, opts = {})
      return unless allowed? :number
      @children << Twilio::Number.new(number, opts)
      @children[-1]
    end
  end

  class Say
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    attributes :voice, :language, :loop
  end

  class Play
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    attributes :loop
  end

  class Gather
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    attributes :action, :method, :timeout, :finishOnKey, :numDigits
    allowed_verbs :play, :say, :pause
  end

  class Record
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    attributes :action, :method, :timeout, :finishOnKey, :maxLength, :transcribe, :transcribeCallback
  end

  class Dial
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    attributes :action, :method, :timeout, :hangupOnStar, :timeLimit, :callerId
    allowed_verbs :number
  end

  class Redirect
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    attributes :method
  end

  class Pause
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    attributes :length
  end

  class Hangup
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
  end

  class Number
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    attributes :sendDigits, :url
  end

  class Response
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    allowed_verbs :say, :play, :gather, :record, :dial, :redirect, :pause, :hangup
  end

  module ControllerHooks
    def add_hook(hook, name, code)
      session[:twilio_hooks] ||= {}
      session[:twilio_hooks][hook] ||= {}
      session[:twilio_hooks][hook][name] = code
      return nil
    end

    def remove_hook(hook, name)
      session[:twilio_hooks] ||= {}
      session[:twilio_hooks][hook] ||= {}
      session[:twilio_hooks][hook].delete(name) if session[:twilio_hooks][hook][name]
      return nil
    end

    def run_hook(hook)
      session[:twilio_hooks] ||= {}
      session[:twilio_hooks][hook] ||= {}
      session[:twilio_hooks][hook].each{|name,code| 
        RAILS_DEFAULT_LOGGER.debug "Running hook '#{name}'"
        eval(code)
      }
      return nil
    end
  end
end
