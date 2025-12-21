using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations
{
    /// <inheritdoc />
    public partial class UpdateUserPostWithDept : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_sys_user_post_sys_post_PostId",
                table: "sys_user_post");

            migrationBuilder.DropForeignKey(
                name: "FK_sys_user_post_sys_user_UserId",
                table: "sys_user_post");

            migrationBuilder.DropPrimaryKey(
                name: "PK_sys_user_post",
                table: "sys_user_post");

            migrationBuilder.AddColumn<long>(
                name: "DeptId",
                table: "sys_user_post",
                type: "bigint",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.AddPrimaryKey(
                name: "PK_sys_user_post",
                table: "sys_user_post",
                columns: new[] { "UserId", "PostId", "DeptId" });

            migrationBuilder.CreateIndex(
                name: "IX_sys_user_post_DeptId",
                table: "sys_user_post",
                column: "DeptId");

            migrationBuilder.AddForeignKey(
                name: "FK_sys_user_post_sys_dept_DeptId",
                table: "sys_user_post",
                column: "DeptId",
                principalTable: "sys_dept",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_sys_user_post_sys_post_PostId",
                table: "sys_user_post",
                column: "PostId",
                principalTable: "sys_post",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_sys_user_post_sys_user_UserId",
                table: "sys_user_post",
                column: "UserId",
                principalTable: "sys_user",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_sys_user_post_sys_dept_DeptId",
                table: "sys_user_post");

            migrationBuilder.DropPrimaryKey(
                name: "PK_sys_user_post",
                table: "sys_user_post");

            migrationBuilder.DropIndex(
                name: "IX_sys_user_post_DeptId",
                table: "sys_user_post");

            migrationBuilder.DropColumn(
                name: "DeptId",
                table: "sys_user_post");

            migrationBuilder.AddPrimaryKey(
                name: "PK_sys_user_post",
                table: "sys_user_post",
                columns: new[] { "UserId", "PostId" });
        }
    }
}
