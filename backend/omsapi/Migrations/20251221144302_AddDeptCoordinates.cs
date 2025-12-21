using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations
{
    /// <inheritdoc />
    public partial class AddDeptCoordinates : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<double>(
                name: "X",
                table: "sys_dept",
                type: "double",
                nullable: true);

            migrationBuilder.AddColumn<double>(
                name: "Y",
                table: "sys_dept",
                type: "double",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "X",
                table: "sys_dept");

            migrationBuilder.DropColumn(
                name: "Y",
                table: "sys_dept");
        }
    }
}
