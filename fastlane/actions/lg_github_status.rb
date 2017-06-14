module Fastlane
  module Actions
    module SharedValues
    end

    class LgGithubStatusAction < Action


      def self.run(params)
        require "octokit"
        require "crack"

        username = params[:gh_user]
        password = params[:gh_password]
        repo = params[:gh_repository]
        pullRequest = params[:gh_pull_request]
        resultsUrl = params[:scan_results_url]

        if pullRequest.nil? || pullRequest.empty?
          prTryout = Actions.sh "git name-rev --name-only HEAD | tr -d -c 0-9"
          if prTryout.nil? || prTryout.empty?      
            UI.error "Github pull request not provided!"
            exit 1
          end
          pullRequest = prTryout
        else
          UI.message "Selected #{pullRequest} pullRequest".blue
        end

        client = Octokit::Client.new(:login => username, :password => password)
        commits = client.pull_request_commits(repo, pullRequest.to_i)
        localLastCommit = nil 
        if !commits.last.nil? 
          localLastCommit = commits.last.sha
        end

        if localLastCommit.nil?
            UI.error "Couldn't find last commit"
            exit 1
        end

        if params[:gh_status_finished]
          junitResult = params[:scan_results_junit]
          resultsUrl = params[:scan_results_url]
          if junitResult.nil?
            client.create_status(repo, localLastCommit, 'error', { :context => "Tests", :target_url => nil, :description => "No results file provided!" })       
            UI.error "No results file provided!"
            exit 1
          end
          if !File.file?(junitResult)
            client.create_status(repo, localLastCommit, 'error', { :context => "Tests", :target_url => nil, :description => "No results file found!" })       
            UI.error "No results file found!"
            exit 1
          end
          hashResult = Crack::XML.parse(File.read(junitResult))
          tests = hashResult['testsuites']['tests']
          failures = hashResult['testsuites']['failures']

          if failures.to_i == 0 
            client.create_status(repo, localLastCommit, 'success', { :context => "Tests", :target_url => resultsUrl, :description => "All #{tests} tests passed!!" })
          else
            client.create_status(repo, localLastCommit, 'failure', { :context => "Tests", :target_url => resultsUrl, :description => "Failed #{failures} tests from a total of #{tests}" })
          end
        else
          client.create_status(repo, localLastCommit, 'pending', { :context => "Tests", :target_url => nil, :description => "Testing started, just wait a few minutes" })
        end
      end



      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Sets the status on a github PR"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :gh_user,
                                       env_name: "GITHUB_USER",
                                       description: "Github user name",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :gh_password,
                                       env_name: "GITHUB_PASSWORD",
                                       description: "Github password",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :gh_repository,
                                       env_name: "GITHUB_REPOSITORY",
                                       description: "Github repository i.e:   letgoapp/letgo-ios",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :gh_pull_request,
                                       env_name: "GITHUB_PULL_REQUEST",
                                       description: "Github pull request number",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :gh_status_finished,
                                       env_name: "STATUS_FINISHED",
                                       description: "Whether is finished and results must be parsed",
                                       is_string: false,
                                       default_value: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :scan_results_junit,
                                       env_name: "SCAN_RESULTS_JUNIT",
                                       description: "scan results in junit xml",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :scan_results_url,
                                       env_name: "SCAN_RESULTS_URL",
                                       description: "scan results link url",
                                       optional: true)
        ]
      end

      def self.output
        []
      end

      def self.author
        'Letgo'
      end

      def self.is_supported?(platform)
        platform == :ios || platform == :android
      end
    end
  end
end