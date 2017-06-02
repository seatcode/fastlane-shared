module Fastlane
  module Actions
    module SharedValues
    end

    # Asks and Raises an exception and stop the lane execution if the repo is not on a specific branch
    class CheckGitBranchAction < Action
      def self.run(params)
        branch = params[:branch]
        branch_expr = /#{branch}/
        if !(Actions.git_branch =~ branch_expr)
          continue = ask("\n\nWARNING! You are in a branch that doesn't match `#{branch}`, do you want yo continue? (y/n)".yellow)
          if continue.nil? || continue != "y"
            UI.user_error!("Git is not on a branch matching `#{branch}`. Current branch is `#{Actions.git_branch}`! Please ensure the repo is checked out to the correct branch.")
          end
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Asks you and raises an exception if not on a specific git branch"
      end

      def self.details
        [
          'This action will check if your git repo is checked out to a specific branch.',
          'You may only want to make releases from a specific branch, so `check_git_branch`',
          'will ask if you want to continue in case it was executed in an incorrect branch.'
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :branch,
                                       env_name: "FL_CHECK_GIT_BRANCH_NAME",
                                       description: "The branch that should be checked for. String that can be either the full name of the branch or a regex to match",
                                       is_string: true,
                                       default_value: 'master')
        ]
      end

      def self.output
        []
      end

      def self.author
        ['elikohen']
      end

      def self.example_code
        [
          "check_git_branch # defaults to `master` branch",
          "check_git_branch(
            branch: 'develop'
          )"
        ]
      end

      def self.category
        :source_control
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
