# -*- coding: utf-8 -*-
class CharworkOutput < Fluent::Output
  require 'uri'
  require 'net/http'
  Fluent::Plugin.register_output('chatwork', self)

  config_param :token, :string, :default => nil
  config_param :room_id, :string, :default => nil

  def emit(tag, es, chain)
    chain.next
    es.each do |time, record|
      message = "tag: #{tag} \nmessage: #{record}"
      chatworkPost(message)
    end
  end

  def chatworkPost(message)
    uri = "https://api.chatwork.com/v1/rooms/#{@room_id}/messages"
    http_request(uri, {:body => message})
  end

  def http_request(uri, query_hash={})
    query = query_hash.map{|k, v| "#{k}=#{v}"}.join('&')        #ハッシュをオプションの書式に変換
    query_escaped = URI.escape(query)
    uri_parsed = URI.parse(uri)

    response = nil

    request = Net::HTTP::Post.new(uri_parsed.request_uri, initheader = {'X-ChatWorkToken' => @token})
    request.body = query_escaped

    http = Net::HTTP.new(uri_parsed.host, uri_parsed.port)
    http.use_ssl = true

    http.set_debug_output $stderr

    http.start do |h|
      response = h.request(request)
    end
  end
end
