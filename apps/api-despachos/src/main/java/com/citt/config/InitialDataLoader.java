package com.citt.config;

import com.citt.persistence.entity.Despacho;
import com.citt.persistence.repository.DespachoRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.List;

@Component
public class InitialDataLoader implements CommandLineRunner {

    private final DespachoRepository despachoRepository;
    private final boolean seedEnabled;

    public InitialDataLoader(
            DespachoRepository despachoRepository,
            @Value("${app.seed.enabled:true}") boolean seedEnabled) {
        this.despachoRepository = despachoRepository;
        this.seedEnabled = seedEnabled;
    }

    @Override
    public void run(String... args) {
        if (!seedEnabled || despachoRepository.count() > 0) {
            return;
        }

        despachoRepository.saveAll(List.of(
                createDespacho(
                        LocalDate.now().plusDays(1),
                        "LTBK-42",
                        1,
                        1L,
                        "Av. Providencia 1234, Providencia",
                        249990L,
                        false),
                createDespacho(
                        LocalDate.now(),
                        "HRDV-18",
                        1,
                        2L,
                        "Av. Apoquindo 4501, Las Condes",
                        189990L,
                        true),
                createDespacho(
                        LocalDate.now().plusDays(2),
                        "MKPL-77",
                        2,
                        3L,
                        "Camino El Alba 9200, La Reina",
                        79990L,
                        false)
        ));
    }

    private Despacho createDespacho(
            LocalDate fechaDespacho,
            String patenteCamion,
            int intento,
            Long idCompra,
            String direccionCompra,
            Long valorCompra,
            boolean despachado) {
        Despacho despacho = new Despacho();
        despacho.setFechaDespacho(fechaDespacho);
        despacho.setPatenteCamion(patenteCamion);
        despacho.setIntento(intento);
        despacho.setIdCompra(idCompra);
        despacho.setDireccionCompra(direccionCompra);
        despacho.setValorCompra(valorCompra);
        despacho.setDespachado(despachado);
        return despacho;
    }
}
