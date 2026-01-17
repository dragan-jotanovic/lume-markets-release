import domain.DeploymentDescriptor
import domain.EnvironmentType
import domain.ProjectDescriptor
import domain.ProjectGroup
import domain.ProjectType

object Configuration {

    const val GITHUB_ORG = "dragan-jotanovic"
    const val VCS_SECURE_TOKEN = "credentialsJSON:1ed61314-4f78-4c3d-8511-f61cc0168098"
    const val VCS_PREFIX = "https://github.com/${GITHUB_ORG}/"

    const val GIT_EMAIL = "teamcity@lucera.com"
    const val GIT_USERNAME = "teamcity"
    const val DOCKER_BUILD_IMAGE = "repo.prd.lucera.com/lume-release-build:0.2.0"

    // Parent release project
    const val RELEASE_REPO_NAME = "lume-markets-release"
    const val VARS_REPO_NAME = "lume-vars"
    // Define subprojects
    val SUBPROJECTS: ArrayList<ProjectDescriptor> = arrayListOf(
        ProjectDescriptor("core-backend", ProjectGroup.SubProjects, ProjectType.SHELL),
        ProjectDescriptor("venue-adapters", ProjectGroup.SubProjects, ProjectType.SHELL)
    )

    // Define deployments
    val DEPLOYMENTS: ArrayList<DeploymentDescriptor> = arrayListOf(
        DeploymentDescriptor("daiwa", EnvironmentType.DEV),
        DeploymentDescriptor("daiwa", EnvironmentType.DEMO),
        DeploymentDescriptor("daiwa", EnvironmentType.QA),
        DeploymentDescriptor("daiwa", EnvironmentType.PROD),
        DeploymentDescriptor("cantor", EnvironmentType.DEMO),
        DeploymentDescriptor("cantor", EnvironmentType.PROD),
        DeploymentDescriptor("baml", EnvironmentType.DEMO),
        DeploymentDescriptor("baml", EnvironmentType.PROD),
    )
}
