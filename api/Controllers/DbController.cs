using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace api.Controllers;

// Connects to a database and gets list of DBs
[ApiController]
[Route("db")]
public class DbController : ControllerBase
{
    [HttpGet]
    public IActionResult Get()
    {
        var connectionString = Environment.GetEnvironmentVariable("CONNECTION_STRING");
        var result = new List<string>();
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            connection.Open();       
            String sql = "SELECT name FROM sys.databases";
            
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        result.Add(reader.GetString(0));
                    }
                }
            }                    
        }

        return new OkObjectResult(result);
    }
}
