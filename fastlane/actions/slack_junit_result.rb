module Fastlane
  module Actions

    # Raises an exception and stop the lane execution if the repo is not in a clean state
    class SlackJunitResultAction < Action
      def self.run(params)

        require "crack"

        files = params[:junit_files]
        file_titles = params[:file_titles]
        slack_payload = Hash.new
        total_tests = 0
        total_failures = 0
        files.each_with_index do |file, index|
          message = ""
          if !file.nil? && File.file?(file)
            hashResult = Crack::XML.parse(File.read(file))
            tests = hashResult['testsuites']['tests']
            failures = hashResult['testsuites']['failures']
            total_tests = total_tests + tests.to_i
            total_failures = total_failures + failures.to_i
            if failures.to_i == 0
              message = "All #{tests} tests passed! :tada:"
            else
              message = "Failed #{failures} tests from a total of #{tests} :warning:"
            end
          else 
            message = "File not found"
          end
          slack_payload[file_titles[index]] = message
        end


        message = ""
        if files.count == 0
          message = "No result file provided"
        elsif files.count == 1 
          message = "Results:"
        elsif total_failures == 0
          message = "All #{total_tests} tests passed! :tada:"
        else
          message = "Failed #{total_failures} tests from a total of #{total_tests} :warning:"
        end

        other_action.slack(
          message: message,
          success: total_failures == 0,
          channel: "#mobile",
          payload: slack_payload,
          use_webhook_configured_username_and_icon: false,
          username: params[:slack_user],
          icon_url: "https://marketplace.canva.com/MACL--W9rUA/1/thumbnail_large/canva-robot-android-automation-icon-MACL--W9rUA.png",
          default_payloads: [],
        )

      end

      def self.description
        "Reads results from junit files and posts the result to slack"
      end

      def self.output
        [ ]
      end

      def self.author
        ["elikohen"]
      end

      def self.category
        :notifications
      end

      def self.example_code
        ["slack_junit_result(slack_title: 'Project X Nightly build',
                             junit_files: ['./scanresults/test1.xml', './scanresults/test2.xml'], 
                             file_titles: ['UI Tests', 'Unit Tests'])"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :slack_user,
                                       env_name: "SCAN_RESULTS_SLACK_USER",
                                       description: "User for slack message",
                                       optional: false),           
          FastlaneCore::ConfigItem.new(key: :junit_files,
                                       env_name: "SCAN_RESULTS_JUNIT_FILES",
                                       description: "scan results in junit xml fils",
                                       is_string: false,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :file_titles,
                                       env_name: "SCAN_RESULTS_FILE_TITLES",
                                       description: "Titles of each junit file",
                                       is_string: false,
                                       optional: true),

        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end