// ✅ Repositórios e dependências para plugins (buildscript)
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.1")
    }
}

// ✅ Repositórios para o projeto e subprojetos
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Diretórios de build customizados (se realmente necessário)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ✅ Garante que `:app` seja avaliado primeiro
subprojects {
    project.evaluationDependsOn(":app")
}

// ✅ Tarefa para limpar builds
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}