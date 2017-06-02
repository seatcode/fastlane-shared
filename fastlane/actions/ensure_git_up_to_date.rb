module Fastlane
  module Actions

    # Raises an exception and stop the lane execution if the repo is not in a clean state
    class EnsureGitUpToDateAction < Action
      def self.run(params)
        Actions::EnsureGitStatusCleanAction.run(show_uncommitted_changes: false)

        sh("git fetch")
        local = sh("git rev-parse @")
        remote = sh("git rev-parse @{u}")

        if local != remote
          automatic_pull = ask("Warning! Your branch is not up to date with the Remote, you may need to pull/push your changes, do you want to continue anyway? (y/n)".yellow)
          if automatic_pull != "y"
            UI.user_error!("Your branch is not up to date with the Remote, Sync your branch and restart the process :)")
          end
        end
      end

      def self.description
        "Raises an exception if there are uncommitted git changes or local copy is not up to date with the repo"
      end

      def self.details
        [
          'A sanity check to make sure you are working in a repo that is clean. And your local ',
          'copy is up to date with the branch on the repo. Otherwise launches an exception.'
        ].join("\n")
      end

      def self.output
        [ ]
      end

      def self.author
        ["elikohen"]
      end

      def self.example_code
        ['ensure_git_up_to_date']
      end

      def self.available_options
        [ ]
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