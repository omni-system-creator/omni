using Microsoft.EntityFrameworkCore.Migrations;
using Pgvector;

#nullable disable

namespace omsapi.MigrationsPg
{
    /// <inheritdoc />
    public partial class AddVectorColumn : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Vector>(
                name: "Vector",
                table: "sys_kb_node",
                type: "vector(1024)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Vector",
                table: "sys_kb_node");
        }
    }
}
