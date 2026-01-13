using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations.MySql
{
    /// <inheritdoc />
    public partial class AddProductTypeToPdmEbomItem : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "product_type",
                table: "pdm_ebom_items",
                type: "varchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "")
                .Annotation("MySql:CharSet", "utf8mb4");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "product_type",
                table: "pdm_ebom_items");
        }
    }
}
