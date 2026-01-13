import domain.SubProject
import domain.SubProjectType

object Configuration {
    const val VCS_PREFIX = "https://github.com/dragan-jotanovic/"
    const val GITHUB_TOKEN_CONFIGURATION_PROPERTY = "MY_GITHUB_TOKEN"
    const val GIT_EMAIL = "teamcity@lucera.com"
    const val GIT_USERNAME = "teamcity"
    const val RELEASE_REPO_NAME = "lume-markets-release"
    const val RELEASE_IT_DOCKER_IMAGE = "repo.prd.lucera.com/release-it-docker:0.8.0"
    val SUBPROJECTS: ArrayList<SubProject> = arrayListOf(
        SubProject("core-backend", SubProjectType.SHELL),
        SubProject("venue-adapters", SubProjectType.SHELL)
    )
}
