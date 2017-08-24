module Fastlane
  module Actions
    module SharedValues
      ANDROID_VERSION_NAME = :ANDROID_VERSION_NAME
      ANDROID_VERSION_CODE = :ANDROID_VERSION_CODE
    end

    class UpdateAndroidVersionAction < Action

      def self.run(params)
        version_name = params[:version_name]
        version_code = params[:version_code]
        autoincrement = params[:autoincrement] #will only work if version_code is not passed
        project_root = params[:project_root]
        module_name = params[:module_name]

        if project_root
          changeDirCommand = "cd #{project_root}"
          UI.message changeDirCommand
          Actions.sh changeDirCommand
        end

        version_code = getBuildValue(".", "androidVersionCode") 
        version_name = getBuildValue(".", "androidVersionName")

        setBuildValue(".", "androidVersionCode", 27)
        setBuildValue(".", "androidVersionName", "7.8.9")

        # if version_code.nil? && autoincrement
        #   other_action.increment_version_code(gradle_file_path: "./build.gradle", version_code: nil, ext_constant_name: "androidVersionCode")
        #   version_code = other_action.get_version_code(gradle_file_path: "./build.gradle", ext_constant_name: "androidVersionCode")
        # elsif version_code != nil
        #   other_action.increment_version_code(app_folder_name: module_name, gradle_file_path: "./build.gradle", version_code: version_code, ext_constant_name: "androidVersionCode")
        # else
        #   version_code = other_action.get_version_code(app_folder_name: module_name, gradle_file_path: "./build.gradle", ext_constant_name: "androidVersionCode")
        # end

        # if version_name != nil
        #   other_action.increment_version_name(app_folder_name: module_name, version_name: version_name, ext_constant_name: "androidVersionName")
        # else
        #   version_name = other_action.get_version_name(app_folder_name: module_name, ext_constant_name: "androidVersionName")
        # end

        UI.message "Name: #{version_name} Code: #{version_code}".blue

        Actions.lane_context[SharedValues::ANDROID_VERSION_NAME] = version_name
        Actions.lane_context[SharedValues::ANDROID_VERSION_CODE] = version_code
      end

      def self.getBuildValue(fileFolder, key)
        value = ""
        found = false
        Dir.glob("#{fileFolder}/build.gradle") do |path|
          begin
            File.open(path, 'r') do |file|
              file.each_line do |line|
                unless line.include? "#{key}" and !found
                  next
                end
                components = line.strip.split(' ')
                value = components.last.tr("\"", "").tr("\'", "")
                break
              end
              file.close
            end
          end
        end
        return value
      end

      def self.setBuildValue(fileFolder, key, newValue)
        found = false
        Dir.glob("#{fileFolder}/build.gradle") do |path|
          begin
            temp_file = Tempfile.new('versioning')
            File.open(path, 'r') do |file|
              file.each_line do |line|
                unless line.include? "#{key} " and !found
                  temp_file.puts line
                  next
                end
                components = line.strip.split(' ')
                value = components.last.tr("\"", "").tr("\'", "")
                line.replace line.sub(value, newValue.to_s)
                found = true
                temp_file.puts line
              end
              file.close
            end
            temp_file.rewind
            temp_file.close
            FileUtils.mv(temp_file.path, path)
            temp_file.unlink
          end
        end
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
                                       env_name: "UPDATE_ANDROID_VERSION_NAME",
                                       description: "Version name (ak 1.0.2",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :version_code,
                                       env_name: "UPDATE_ANDROID_VERSION_CODE",
                                       description: "Version code (ak build number)",
                                       optional: true),  
          FastlaneCore::ConfigItem.new(key: :autoincrement,
                                       env_name: "UPDATE_ANDROID_VERSION_AUTOINCREMENT",
                                       description: "TRUE if you want to autoincrement the Version code",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :project_root,
                                       env_name: "UPDATE_ANDROID_VERSION_PROJECT_ROOT",
                                       description: "[Optional] Path to the project root. If not provided will use current directory",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :module_name,
                                       env_name: "UPDATE_ANDROID_VERSION_MODULE_NAME",
                                       description: "[Optional] App/Lib module name",
                                       optional: true)
        ]
      end

      def self.output
        [
          ['ANDROID_VERSION_NAME', 'The new version name'],
          ['ANDROID_VERSION_CODE', 'The new version code']
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
