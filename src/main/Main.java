package main;

import java.util.List;

import stat.StatNombreclients;

public class Main {
    public static void main(String[] args) {
        try {
                StatNombreclients nombreclientsparans = new StatNombreclients();
                List<StatNombreclients> getNombreclientsparans = nombreclientsparans.getAll();
                for (StatNombreclients v_nombreclientsparan : getNombreclientsparans) {
                    System.out.println("nombre "+v_nombreclientsparan.getMois());
                    System.out.println("nombre client "+v_nombreclientsparan.getNombre_clients());
                    
                }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
