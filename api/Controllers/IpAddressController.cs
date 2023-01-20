using Microsoft.AspNetCore.Mvc;

namespace api.Controllers;

// Will find the public IP of the service
[ApiController]
[Route("ip")]
public class IpAddressController : ControllerBase
{
    // https://www.thecodebuzz.com/using-httpclient-best-practices-and-anti-patterns/
    static readonly HttpClient client = new HttpClient();

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        var ip = await client.GetStringAsync("https://api.ipify.org");
        return Ok(ip);
    }
}
