using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations
{
    /// <inheritdoc />
    public partial class UpdateUserRoleRelation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_sys_user_role_RoleId",
                table: "sys_user_role",
                column: "RoleId");

            migrationBuilder.AddForeignKey(
                name: "FK_sys_user_role_sys_role_RoleId",
                table: "sys_user_role",
                column: "RoleId",
                principalTable: "sys_role",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_sys_user_role_sys_user_UserId",
                table: "sys_user_role",
                column: "UserId",
                principalTable: "sys_user",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_sys_user_role_sys_role_RoleId",
                table: "sys_user_role");

            migrationBuilder.DropForeignKey(
                name: "FK_sys_user_role_sys_user_UserId",
                table: "sys_user_role");

            migrationBuilder.DropIndex(
                name: "IX_sys_user_role_RoleId",
                table: "sys_user_role");
        }
    }
}
