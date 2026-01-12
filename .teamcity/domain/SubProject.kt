package domain

class SubProject(val name: String, val type: SubProjectType) {
    fun normalizedName(): String {
        return name.replace('-', '_');
    }
}