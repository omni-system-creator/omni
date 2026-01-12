using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations
{
    /// <inheritdoc />
    public partial class AddConfigTypeToSystemConfig : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Type",
                table: "sys_config",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.UpdateData(
                table: "sys_config",
                keyColumn: "Id",
                keyValue: 1L,
                column: "Type",
                value: 0);

            migrationBuilder.UpdateData(
                table: "sys_config",
                keyColumn: "Id",
                keyValue: 2L,
                column: "Type",
                value: 4);

            migrationBuilder.UpdateData(
                table: "sys_config",
                keyColumn: "Id",
                keyValue: 3L,
                column: "Type",
                value: 0);

            migrationBuilder.UpdateData(
                table: "sys_config",
                keyColumn: "Id",
                keyValue: 4L,
                column: "Type",
                value: 1);

            migrationBuilder.UpdateData(
                table: "sys_config",
                keyColumn: "Id",
                keyValue: 5L,
                column: "Type",
                value: 1);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Type",
                table: "sys_config");
        }
    }
}
