package com.proxwiz.server;

import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;

/** Servlet for proximity queries.
 */

@WebServlet("/pq")
public class ProximityQuery extends HttpServlet {
  @Override
  public void doGet(HttpServletRequest request,
                    HttpServletResponse response)
      throws ServletException, IOException {
    response.setContentType("text/html");
    PrintWriter out = response.getWriter();
    out.println
      ("JSON proximit output goes here.");
  }
}
