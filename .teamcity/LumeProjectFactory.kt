import domain.ProjectDescriptor
import domain.ProjectType
import jetbrains.buildServer.configs.kotlin.Project
import projects.LumeShellProject

object LumeProjectFactory {

    fun createProject(subProject: ProjectDescriptor): Project {
        return when(subProject.type) {
            ProjectType.SHELL -> LumeShellProject.create(subProject)
            ProjectType.MAVEN -> TODO()
            ProjectType.GRADLE -> TODO()
            ProjectType.NODE -> TODO()
        }
    }
}
