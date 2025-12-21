using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations
{
    /// <inheritdoc />
    public partial class AddPostAndRoleUpdates : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "DeptId",
                table: "sys_user",
                type: "bigint",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "DeptId",
                table: "sys_role",
                type: "bigint",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "sys_dept",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    ParentId = table.Column<long>(type: "bigint", nullable: true),
                    Name = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Code = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Leader = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Phone = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Email = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime(6)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_dept", x => x.Id);
                    table.ForeignKey(
                        name: "FK_sys_dept_sys_dept_ParentId",
                        column: x => x.ParentId,
                        principalTable: "sys_dept",
                        principalColumn: "Id");
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "sys_post",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    Code = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Name = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    Remark = table.Column<string>(type: "varchar(200)", maxLength: 200, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    CreatedAt = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime(6)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_post", x => x.Id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "sys_role_inheritance",
                columns: table => new
                {
                    ParentRoleId = table.Column<long>(type: "bigint", nullable: false),
                    ChildRoleId = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_role_inheritance", x => new { x.ParentRoleId, x.ChildRoleId });
                    table.ForeignKey(
                        name: "FK_sys_role_inheritance_sys_role_ChildRoleId",
                        column: x => x.ChildRoleId,
                        principalTable: "sys_role",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_sys_role_inheritance_sys_role_ParentRoleId",
                        column: x => x.ParentRoleId,
                        principalTable: "sys_role",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "sys_user_post",
                columns: table => new
                {
                    UserId = table.Column<long>(type: "bigint", nullable: false),
                    PostId = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_user_post", x => new { x.UserId, x.PostId });
                    table.ForeignKey(
                        name: "FK_sys_user_post_sys_post_PostId",
                        column: x => x.PostId,
                        principalTable: "sys_post",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_sys_user_post_sys_user_UserId",
                        column: x => x.UserId,
                        principalTable: "sys_user",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.UpdateData(
                table: "sys_role",
                keyColumn: "Id",
                keyValue: 1L,
                column: "DeptId",
                value: null);

            migrationBuilder.UpdateData(
                table: "sys_user",
                keyColumn: "Id",
                keyValue: 1L,
                column: "DeptId",
                value: null);

            migrationBuilder.CreateIndex(
                name: "IX_sys_user_DeptId",
                table: "sys_user",
                column: "DeptId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_role_DeptId",
                table: "sys_role",
                column: "DeptId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_dept_ParentId",
                table: "sys_dept",
                column: "ParentId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_post_Code",
                table: "sys_post",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_sys_role_inheritance_ChildRoleId",
                table: "sys_role_inheritance",
                column: "ChildRoleId");

            migrationBuilder.CreateIndex(
                name: "IX_sys_user_post_PostId",
                table: "sys_user_post",
                column: "PostId");

            migrationBuilder.AddForeignKey(
                name: "FK_sys_role_sys_dept_DeptId",
                table: "sys_role",
                column: "DeptId",
                principalTable: "sys_dept",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_sys_user_sys_dept_DeptId",
                table: "sys_user",
                column: "DeptId",
                principalTable: "sys_dept",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_sys_role_sys_dept_DeptId",
                table: "sys_role");

            migrationBuilder.DropForeignKey(
                name: "FK_sys_user_sys_dept_DeptId",
                table: "sys_user");

            migrationBuilder.DropTable(
                name: "sys_dept");

            migrationBuilder.DropTable(
                name: "sys_role_inheritance");

            migrationBuilder.DropTable(
                name: "sys_user_post");

            migrationBuilder.DropTable(
                name: "sys_post");

            migrationBuilder.DropIndex(
                name: "IX_sys_user_DeptId",
                table: "sys_user");

            migrationBuilder.DropIndex(
                name: "IX_sys_role_DeptId",
                table: "sys_role");

            migrationBuilder.DropColumn(
                name: "DeptId",
                table: "sys_user");

            migrationBuilder.DropColumn(
                name: "DeptId",
                table: "sys_role");
        }
    }
}
