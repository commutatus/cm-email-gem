require "cm_email/version"
require 'cm_email/configuration'

module Cm_email
  class << self
    attr_accessor :configuration
    require 'net/http'
    require 'uri'
    require 'json'

    def configuration
      @configuration ||= Configuration.new
    end

    def reset
      @configuration = Configuration.new
    end

    def configure
      yield(configuration)
    end

    def create_contact(first_name, email, last_name = '', date_of_birth = '', country = '')
      request_body = {
        api_key: configuration.api_key,
        first_name: first_name,
        email: email,
        last_name: last_name,
        date_of_birth: date_of_birth,
        country: country
      }
      create_response = request_cm_email('/api/contacts', request_body)
    end

    def unsubscribe_contact(contact_email)
      request_body = {
        api_key: configuration.api_key,
        contact_email: contact_email
      }
      create_response = request_cm_email('/api/contacts/unsubscribe', request_body)
    end

    def create_segment(name, contact_emails, note = '')
      segment = {}
      segment_contacts = []
      contact_emails.each do |contact_email|
        segment_contacts << {contact_email: contact_email}
      end
      request_body = {
        api_key: configuration.api_key,
        name: name,
        note: note,
        segment: {
          segment_contacts: segment_contacts
        }
      }
      create_response = request_cm_email('/api/segments', request_body)
    end

    def remove_segment_contact(contact_email, segment_name)
      request_body = {
        api_key: configuration.api_key,
        contact_email: contact_email,
        segment_name: segment_name
      }
      create_response = request_cm_email('/api/segments/segment_contacts/remove', request_body, 'delete')
    end

    def add_segment_contact(contact_email, segment_name)
      request_body = {
        api_key: configuration.api_key,
        contact_email: contact_email,
        segment: segment_name
      }
      create_response = request_cm_email('/api/segments/segment_contacts/add', request_body)
    end

    def request_cm_email(path, request_body, method = 'post')
      #conditional statement below is temporary and will be changed to prod url later.
      if Rails.env == 'development' || Rails.env == 'staging'
        domain_url = 'https://staging.cm-email.commutatus.com/'
      else
        domain_url = 'https://cm-email.commutatus.com/'
      end
      uri = URI.parse(domain_url + path)
      header = {'Content-Type': 'application/json'}
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = method == 'delete'? Net::HTTP::Delete.new(uri.request_uri, header) : Net::HTTP::Post.new(uri.request_uri, header)
      puts request_body.to_json
      request.body = request_body.to_json
      # Send the request
      response = http.request(request)
      return JSON.parse(response.body)
    end

  end
end
