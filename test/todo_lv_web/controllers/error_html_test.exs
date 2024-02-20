defmodule TodoLvWeb.ErrorHTMLTest do
  use TodoLvWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  test "renders 404.html" do
    assert render_to_string(TodoLvWeb.ErrorHTML, "404", "html", []) == "<div class=\"min-h-screen flex flex-grow items-center justify-center bg-gray-50\">\n    <div class=\"rounded-lg bg-white p-8 text-center shadow-xl\">\n      <h1 class=\"mb-4 text-4xl font-bold\">404</h1>\n      <p class=\"text-gray-600\">Oops! The page you are looking for could not be found.</p>\n      <a href=\"/\" class=\"mt-4 inline-block rounded bg-blue-500 px-4 py-2 font-semibold text-white hover:bg-blue-600\"> Go back to Home </a>\n    </div>\n  </div>"
  end

  test "renders 500.html" do
    assert render_to_string(TodoLvWeb.ErrorHTML, "500", "html", []) == "<div class=\"bg-gray-200 w-full px-16 md:px-0 h-screen flex items-center justify-center\">\n    <div class=\"bg-white border border-gray-200 flex flex-col items-center justify-center px-4 md:px-8 lg:px-24 py-8 rounded-lg shadow-2xl\">\n        <p class=\"text-6xl md:text-7xl lg:text-9xl font-bold tracking-wider text-gray-300\">500</p>\n        <p class=\"text-2xl md:text-3xl lg:text-5xl font-bold tracking-wider text-gray-500 mt-4\">Server Error</p>\n        <p class=\"text-gray-500 mt-8 py-2 border-y-2 text-center\">Whoops, something went wrong on our servers.</p>\n    </div>\n</div>"
  end
end
