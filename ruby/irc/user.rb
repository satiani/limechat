# Created by Satoshi Nakagawa.
# You can redistribute it and/or modify it under the Ruby's license or the GPL2.

class User
  attr_accessor :nick, :username, :address, :o, :v
  attr_reader :incoming_weight, :outgoing_weight
  
  def initialize(nick, *args)
    @nick = nick
    @outgoing_weight = 0
    @incoming_weight = 0
    @last_faded_weights = Time.now
    @username = args[0] || ''
    @address = args[1] || ''
    @o = args[2] || false
    @v = args[3] || false
  end
  
  def to_s
    mark + @nick
  end
  
  def mark
    if @o
      '@'
    elsif @v
      '+'
    else
      ''
    end
  end
  
  # the weighting system keeps track of who you are talking to
  # and who is talking to you... incoming messages are not weighted
  # as highly as the messages you send to someone
  #
  # outgoing_conversation! is called when someone sends you a message
  # incoming_conversation! is called when you talk to someone
  #
  # the conventions are probably backwards if you think of them from
  # the wrong able, I'm open to suggestions - Josh Goebel
  
  def weight
    decay_conversation # fade the conversation since the last time we spoke
    incoming_weight + outgoing_weight
  end
  
  def outgoing_conversation!
    change = (outgoing_weight == 0) ? 20 : 5
    @outgoing_weight += change
  end

  def incoming_conversation!
    change = (incoming_weight == 0) ? 100 : 20
    @incoming_weight += change
  end
  
  # make our conversations decay overtime based on a half-life of one minute
  def decay_conversation
    # we half-life the conversation every minute
    units = (Time.now - @last_faded_weights)/60
    if units > 1 
      @last_faded_weights = Time.now      
      if incoming_weight > 0 or outgoing_weight > 0
        @outgoing_weight /= (2**units) if outgoing_weight > 0
        @incoming_weight /= (2**units) if incoming_weight > 0
      end
    end
  end
end
