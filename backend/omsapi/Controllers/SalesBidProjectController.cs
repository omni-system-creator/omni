using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Dtos.Sales;
using omsapi.Services.Interfaces;
using omsapi.Models.Common;

namespace omsapi.Controllers
{
    [ApiController]
    [Route("api/sales/bid-project")]
    public class SalesBidProjectController : ControllerBase
    {
        private readonly ISalesBidProjectService _service;

        public SalesBidProjectController(ISalesBidProjectService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<SalesBidProjectDto>>> GetList(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? keyword = null,
            [FromQuery] string? region = null,
            [FromQuery] string? type = null,
            [FromQuery] string? status = null)
        {
            var result = await _service.GetListAsync(page, pageSize, keyword, region, type, status);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<SalesBidProjectDto>> GetById(string id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null) return NotFound();
            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<SalesBidProjectDto>> Create([FromBody] CreateSalesBidProjectDto dto)
        {
            var result = await _service.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<SalesBidProjectDto>> Update(string id, [FromBody] UpdateSalesBidProjectDto dto)
        {
            var result = await _service.UpdateAsync(id, dto);
            if (result == null) return NotFound();
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(string id)
        {
            var success = await _service.DeleteAsync(id);
            if (!success) return NotFound();
            return NoContent();
        }
    }
}
