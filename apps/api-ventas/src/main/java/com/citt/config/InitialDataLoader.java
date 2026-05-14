package com.citt.config;

import com.citt.persistence.entity.Venta;
import com.citt.persistence.repository.VentaRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.List;

@Component
public class InitialDataLoader implements CommandLineRunner {

    private final VentaRepository ventaRepository;
    private final boolean seedEnabled;

    public InitialDataLoader(
            VentaRepository ventaRepository,
            @Value("${app.seed.enabled:true}") boolean seedEnabled) {
        this.ventaRepository = ventaRepository;
        this.seedEnabled = seedEnabled;
    }

    @Override
    public void run(String... args) {
        if (!seedEnabled || ventaRepository.count() > 0) {
            return;
        }

        ventaRepository.saveAll(List.of(
                Venta.builder()
                        .direccionCompra("Av. Providencia 1234, Providencia")
                        .valorCompra(249990)
                        .fechaCompra(LocalDate.now().minusDays(4))
                        .despachoGenerado(true)
                        .build(),
                Venta.builder()
                        .direccionCompra("Av. Apoquindo 4501, Las Condes")
                        .valorCompra(189990)
                        .fechaCompra(LocalDate.now().minusDays(3))
                        .despachoGenerado(true)
                        .build(),
                Venta.builder()
                        .direccionCompra("Camino El Alba 9200, La Reina")
                        .valorCompra(79990)
                        .fechaCompra(LocalDate.now().minusDays(1))
                        .despachoGenerado(false)
                        .build()
        ));
    }
}
