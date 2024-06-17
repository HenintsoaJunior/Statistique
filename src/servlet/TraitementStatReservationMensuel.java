package servlet;

import java.io.IOException;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import stat.StatReservationMensuel;

public class TraitementStatReservationMensuel extends HttpServlet{
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            processRequest(request, response);
        } catch (Exception e) {
            throw new ServletException("Erreur lors du traitement de la requête", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            processRequest(request, response);
        } catch (Exception e) {
            throw new ServletException("Erreur lors du traitement de la requête", e);
        }
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        response.setContentType("text/html;charset=UTF-8");
        StatReservationMensuel statReservationMensuel = new StatReservationMensuel();
        List<StatReservationMensuel> getStatReservationMensuel = statReservationMensuel.getAll();

        request.setAttribute("statReservationMensuel", getStatReservationMensuel);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/statReservationMensuel.jsp");
        dispatcher.forward(request, response);
    }
}
