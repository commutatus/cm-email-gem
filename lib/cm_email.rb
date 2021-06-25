require "cm_email/version"
require 'cm_email/configuration'

module CmEmail
  class << self
    attr_accessor :configuration
    require 'net/http'
    require 'uri'
    require 'json'

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    # Either finds and updates, or creates a contact (with status subscribed).
    def create_contact(first_name, email, last_name = '', date_of_birth = '', country = '')
      request_body = {
        first_name: first_name,
        email: email,
        last_name: last_name,
        date_of_birth: date_of_birth,
        country: country
      }
      create_response = request_cm_email('/api/contacts', request_body)
    end

    # Finds the contact and unsubscribes it from every segment.
    def unsubscribe_contact(contact_email)
      request_body = {
        contact_email: contact_email
      }
      create_response = request_cm_email('/api/contacts/unsubscribe', request_body)
    end

    # Creates a segment (with atleast one existing contact).
    # expected format for 'contact_emails' is Array[JSON].
    def create_segment(name, contact_emails, note = '')
      request_body = {
        name: name,
        note: note,
        segment: {
          segment_contacts: contact_emails
        }
      }
      create_response = request_cm_email('/api/segments', request_body)
    end

    def update_segment(existing_name, new_name, note = '')
      request_body = {
        existing_name: existing_name,
        new_name: new_name,
        note: note
      }
      create_response = request_cm_email('/api/segments/update', request_body)
    end

    # Removes contact from the segment.
    def remove_segment_contact(contact_email, segment_name)
      request_body = {
        contact_email: contact_email,
        segment_name: segment_name
      }
      create_response = request_cm_email('/api/segments/segment_contacts/remove', request_body, 'delete')
    end

    # Adds a contact to a segment.
    def add_segment_contact(contact_email, segment_name)
      request_body = {
        contact_email: contact_email,
        segment: segment_name
      }
      create_response = request_cm_email('/api/segments/segment_contacts/add', request_body)
    end

    def request_cm_email(path, request_body, method = 'post')
      domain_url = if api_mode.eql?('staging')
        'https://staging.cm-email.commutatus.com/'
      else
        'https://cm-email.commutatus.com/'
      end
      uri = URI.parse(domain_url + path)
      headers = {'Content-Type': 'application/json', 'Api-Key': api_key}
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = method == 'delete'? Net::HTTP::Delete.new(uri.request_uri, headers) : Net::HTTP::Post.new(uri.request_uri, headers)
      puts request_body.to_json
      request.body = request_body.to_json
      # Send the request
      response = http.request(request)
      return JSON.parse(response.body)
    end

    def api_key
      return configuration.api_key
    end

    def api_mode
      return configuration.api_mode
    end

  end
end
