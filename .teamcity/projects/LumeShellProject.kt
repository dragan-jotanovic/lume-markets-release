package projects

import domain.SubProject
import jetbrains.buildServer.configs.kotlin.FailureAction
import jetbrains.buildServer.configs.kotlin.Project
import jetbrains.buildServer.configs.kotlin.RelativeId
import jetbrains.buildServer.configs.kotlin.buildFeatures.dockerRegistryConnections
import jetbrains.buildServer.configs.kotlin.buildSteps.ScriptBuildStep
import jetbrains.buildServer.configs.kotlin.buildSteps.script
import jetbrains.buildServer.configs.kotlin.vcs.GitVcsRoot

object LumeShellProject: Project() {

    fun create(subProject: SubProject): Project {
        return Project {
            id = RelativeId(subProject.normalizedName())

            name = subProject.name
            description = "Lume release subproject: ${subProject.name}"

            buildType {
                templates(RelativeId("GitHubTriggerNotify"))
                id = RelativeId(subProject.normalizedName() + "_AllBranchBuild")
                name = "Build"

                description = "${subProject.name} regular build for testing a commit"

                vcs {
                    root(RelativeId(subProject.normalizedName() + "_GitHub"))
                }

                steps {
                    script {
                        name = "Build"
                        id = "Build"
                        scriptContent = """
                            ./scripts/build.sh
                        """.trimIndent()
                    }
                    script {
                        name = "Test"
                        id = "Test"
                        scriptContent = """
                            ./scripts/test.sh
                        """.trimIndent()
                    }
                }
            }

            buildType {
                id = RelativeId(subProject.normalizedName() + "_Release")
                name = "Release"

                description = "${subProject.name} release generation"

                vcs {
                    root(RelativeId(subProject.normalizedName() + "_GitHub"))

                    branchFilter = """
                    +:<default>
                    +:release*
                """.trimIndent()
                }

                steps {
                    script {
                        id = "simpleRunner"
                        scriptContent = """
                            release-it-containerized patch --ci
                        """.trimIndent()
                        dockerImage = Configuration.RELEASE_IT_DOCKER_IMAGE
                        dockerImagePlatform = ScriptBuildStep.ImagePlatform.Linux
                    }
                    script {
                        name = "UpdateVersionProp"
                        id = "UpdateVersionProp"
                        scriptContent = """
                            version="$(cat VERSION)"
                            branch="$(git rev-parse --abbrev-ref HEAD)"
                            echo "##teamcity[setParameter name='SERVICE_VERSION' value='v${"$"}{version}']"
                            echo "##teamcity[setParameter name='SERVICE_BRANCH' value='v${"$"}{branch}']"
                        """.trimIndent()
                    }
                }

                features {
                    dockerRegistryConnections {
                        loginToRegistry = on {
                            dockerRegistryId = "PROJECT_EXT_6"
                        }
                    }
                }

                dependencies {
                    snapshot(RelativeId(subProject.normalizedName() + "_AllBranchBuild")) {
                        onDependencyFailure = FailureAction.CANCEL
                    }
                }

                params {
                    param("SERVICE_VERSION", "")
                    param("SERVICE_BRANCH", "")
                }
                outputParams {
                    exposeAllParameters = false
                    param("OUT_SERVICE_VERSION", "%SERVICE_VERSION%")
                    param("OUT_SERVICE_BRANCH", "%SERVICE_BRANCH%")
                }
            }
        }
    }
}
