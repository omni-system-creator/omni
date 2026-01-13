using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations.MySql
{
    /// <inheritdoc />
    public partial class AddChildVersionToEbomStructure : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "child_version",
                table: "pdm_ebom_structure",
                type: "varchar(20)",
                maxLength: 20,
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "child_version",
                table: "pdm_ebom_structure");
        }
    }
}
