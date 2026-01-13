using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations.PostgreSql
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
                type: "character varying(20)",
                maxLength: 20,
                nullable: true);
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
