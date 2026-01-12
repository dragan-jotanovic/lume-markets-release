import domain.SubProject
import domain.SubProjectType
import jetbrains.buildServer.configs.kotlin.Project
import projects.LumeReleaseProject
import projects.LumeShellProject

object LumeProjectFactory {

    fun createProject(subProject: SubProject): Project {
        return when(subProject.type) {
            SubProjectType.SHELL -> LumeShellProject.create(subProject)
            SubProjectType.MAVEN -> TODO()
            SubProjectType.GRADLE -> TODO()
            SubProjectType.NODE -> TODO()
        }
    }
}
