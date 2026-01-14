import domain.SubProject
import domain.SubProjectType

object Configuration {
    const val GITHUB_ORG = "dragan-jotanovic"
    const val VCS_PREFIX = "https://github.com/${GITHUB_ORG}/"
    const val GITHUB_TOKEN_CONFIGURATION_PROPERTY = "MY_GITHUB_TOKEN"
    const val GIT_EMAIL = "teamcity@lucera.com"
    const val GIT_USERNAME = "teamcity"
    const val RELEASE_IT_DOCKER_IMAGE = "repo.prd.lucera.com/lume-release-build:0.2.0"

    // Parent release project
    const val RELEASE_REPO_NAME = "lume-markets-release"
    // Define subprojects
    val SUBPROJECTS: ArrayList<SubProject> = arrayListOf(
        SubProject("core-backend", SubProjectType.SHELL),
        SubProject("venue-adapters", SubProjectType.SHELL)
    )
}
