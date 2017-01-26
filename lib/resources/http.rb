# encoding: utf-8
# copyright: 2017, Criteo
# author: Guilhem Lettron
# license: Apache v2

require 'http'

module Inspec::Resources
  class Http < Inspec.resource(1)
    name 'http'
    desc 'Use the http InSpec audit resource to test http call.'
    example "
      describe http('http://localhost:8080/ping', auth: {user: 'user', pass: 'test'}, params: {format: 'html'}) do
        its('status') { should cmp 200 }
        its('body') { should cmp 'pong' }
        its('Content-Type') { should cmp 'text/html' }
      end
    "

    # rubocop:disable ParameterLists
    def initialize(url, method: 'GET', params: nil, auth: {}, headers: {}, data: nil)
      @url = url
      @method = method
      @params = params
      @auth = auth
      @headers = headers
      @data = data
    end

    def status
      response.status
    end

    def body
      response.to_s
    end

    def method_missing(name)
      response.headers[name.to_s]
    end

    def to_s
      "http #{@method} on #{@url}: #{response}"
    end

    private

    def response
      http = HTTP.headers(@headers)
      http = http.basic_auth(@auth) unless @auth.empty?
      @response ||= http.request(@method, @url, { body: @data, params: @params })
    end
  end
end
