import domain.SubProject
import domain.SubProjectType

object Configuration {
    const val VCS_PREFIX = "https://github.com/dragan-jotanovic/"
    const val GITHUB_TOKEN_CONFIGURATION_PROPERTY = "MY_GITHUB_TOKEN"
    const val RELEASE_REPO_NAME = "lume-markets-release"
    val SUBPROJECTS: ArrayList<SubProject> = arrayListOf(
        SubProject("core-backend", SubProjectType.SHELL),
        SubProject("venue-adapters", SubProjectType.SHELL)
    )
}
