using Microsoft.AspNetCore.Mvc;
using System.Data.Common;
using System.Data.SqlClient;
using System.Net;
using Microsoft.Extensions.Configuration;
using System.Runtime.InteropServices;


namespace Simpleapp.Controllers
{
    [ApiController]
    [Route("")]
    public class LiveController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public LiveController( IConfiguration configuration)
        {
            _configuration = configuration;
        }
        [HttpGet("live")]
        public IActionResult CheckDatabaseConnection()
        {
            try
            {
                string connectionString = _configuration.GetConnectionString("Products_Conn");

                using (var connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    connection.Close();
                }

                return Ok("Well done");
            }
            catch (Exception)
            {
                return StatusCode(503, "Maintenance");
            }
        }
    }
    }