using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations
{
    /// <inheritdoc />
    public partial class AddPermissionQuery : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Query",
                table: "sys_permission",
                type: "varchar(1000)",
                maxLength: 1000,
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.UpdateData(
                table: "sys_permission",
                keyColumn: "Id",
                keyValue: 102L,
                column: "Query",
                value: null);

            migrationBuilder.UpdateData(
                table: "sys_permission",
                keyColumn: "Id",
                keyValue: 103L,
                column: "Query",
                value: null);

            migrationBuilder.UpdateData(
                table: "sys_permission",
                keyColumn: "Id",
                keyValue: 104L,
                column: "Query",
                value: null);

            migrationBuilder.UpdateData(
                table: "sys_permission",
                keyColumn: "Id",
                keyValue: 105L,
                column: "Query",
                value: null);

            migrationBuilder.UpdateData(
                table: "sys_permission",
                keyColumn: "Id",
                keyValue: 106L,
                column: "Query",
                value: null);

            migrationBuilder.UpdateData(
                table: "sys_permission",
                keyColumn: "Id",
                keyValue: 107L,
                column: "Query",
                value: null);

            migrationBuilder.UpdateData(
                table: "sys_permission",
                keyColumn: "Id",
                keyValue: 108L,
                column: "Query",
                value: null);

            migrationBuilder.UpdateData(
                table: "sys_permission",
                keyColumn: "Id",
                keyValue: 109L,
                column: "Query",
                value: null);

            migrationBuilder.UpdateData(
                table: "sys_permission",
                keyColumn: "Id",
                keyValue: 110L,
                column: "Query",
                value: null);

            migrationBuilder.UpdateData(
                table: "sys_permission",
                keyColumn: "Id",
                keyValue: 111L,
                column: "Query",
                value: null);

            migrationBuilder.UpdateData(
                table: "sys_permission",
                keyColumn: "Id",
                keyValue: 112L,
                column: "Query",
                value: null);

            migrationBuilder.UpdateData(
                table: "sys_permission",
                keyColumn: "Id",
                keyValue: 113L,
                column: "Query",
                value: null);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Query",
                table: "sys_permission");
        }
    }
}
