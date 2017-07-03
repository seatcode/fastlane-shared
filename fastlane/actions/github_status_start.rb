module Fastlane
  module Actions
    module SharedValues
    end

    class GithubStatusStartAction < Action


      def self.run(params)
        require "octokit"

        username = params[:gh_user]
        password = params[:gh_password]
        repo = params[:gh_repository]
        pullRequest = params[:gh_pull_request]

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

        client.create_status(repo, localLastCommit, 'pending', { :context => "Tests", :target_url => nil, :description => "Testing started, just wait a few minutes" })
      end



      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Sets a Testing started status on a pull request on github"
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
                                       optional: false)
        ]
      end

      def self.output
        []
      end

      def self.author
        'Eli Kohen'
      end

      def self.is_supported?(platform)
        platform == :ios || platform == :android
      end
    end
  end
end