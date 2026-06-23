package ru.simohin.posusekam.backend

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.autoconfigure.domain.EntityScan
import org.springframework.boot.runApplication
import org.springframework.data.jpa.repository.config.EnableJpaRepositories

@SpringBootApplication
@EntityScan(basePackages = ["ru.simohin.posusekam.models.entity"])
@EnableJpaRepositories(basePackages = ["ru.simohin.posusekam.backend.repository"])
class BackendServiceApplication

fun main(args: Array<String>) {
    runApplication<BackendServiceApplication>(*args)
}
