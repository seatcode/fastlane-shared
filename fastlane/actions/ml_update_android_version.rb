module Fastlane
  module Actions
    module SharedValues
      ML_VERSION_NAME = :ML_VERSION_NAME
      ML_VERSION_CODE = :ML_VERSION_CODE
    end

    class MlUpdateAndroidVersionAction < Action

      def self.run(params)
        version_name = params[:version_name]
        version_code = params[:version_code]
        autoincrement = params[:autoincrement] #will only work if version_code is not passed
        project_root = params[:project_root]

        if project_root
          changeDirCommand = "cd #{project_root}"
          UI.message changeDirCommand
          Actions.sh changeDirCommand
        end

        if version_code.nil? && autoincrement
          Actions::IncrementVersionCodeAction.run(app_folder_name: nil, version_code: nil)
          version_code = Actions::GetVersionCodeAction.run(app_folder_name: nil)
        elsif version_code != nil
          Actions::IncrementVersionCodeAction.run(app_folder_name: nil, version_code: version_code)
        else
          version_code = Actions::GetVersionCodeAction.run(app_folder_name: nil)
        end

        if version_name != nil
          Actions::IncrementVersionNameAction.run(app_folder_name: nil, version_name: version_name)
        else
          version_name = Actions::GetVersionNameAction.run(app_folder_name: nil)
        end

        UI.message "Name: #{version_name} Code: #{version_code}".blue

        Actions.lane_context[SharedValues::ML_VERSION_NAME] = version_name
        Actions.lane_context[SharedValues::ML_VERSION_CODE] = version_code
      end



      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Changes app build number and pushes the change to a specific branch"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version_name,
                                       env_name: "ML_UPDATE_ANDROID_VERSION_NAME",
                                       description: "Version name (ak 1.0.2",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :version_code,
                                       env_name: "ML_UPDATE_ANDROID_VERSION_CODE",
                                       description: "Version code (ak build number)",
                                       optional: true),  
          FastlaneCore::ConfigItem.new(key: :autoincrement,
                                       env_name: "ML_UPDATE_ANDROID_VERSION_AUTOINCREMENT",
                                       description: "TRUE if you want to autoincrement the Version code",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :project_root,
                                       env_name: "ML_UPDATE_ANDROID_VERSION_PROJECT_ROOT",
                                       description: "[Optional] Path to the project root. If not provided will use current directory",
                                       optional: true),
        ]
      end

      def self.output
        [
          ['ML_VERSION_NAME', 'The new version name'],
          ['ML_VERSION_CODE', 'The new version code']
        ]
      end

      def self.author
        'Eli Kohen'
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
