using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations
{
    /// <inheritdoc />
    public partial class AddDeptIdToPost : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "DeptId",
                table: "sys_post",
                type: "bigint",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_sys_post_DeptId",
                table: "sys_post",
                column: "DeptId");

            migrationBuilder.AddForeignKey(
                name: "FK_sys_post_sys_dept_DeptId",
                table: "sys_post",
                column: "DeptId",
                principalTable: "sys_dept",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_sys_post_sys_dept_DeptId",
                table: "sys_post");

            migrationBuilder.DropIndex(
                name: "IX_sys_post_DeptId",
                table: "sys_post");

            migrationBuilder.DropColumn(
                name: "DeptId",
                table: "sys_post");
        }
    }
}
