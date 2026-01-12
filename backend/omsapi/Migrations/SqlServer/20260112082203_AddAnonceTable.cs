using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations.SqlServer
{
    /// <inheritdoc />
    public partial class AddAnonceTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterTable(
                name: "sys_anonce",
                comment: "系统公告表");

            migrationBuilder.AlterColumn<long>(
                name: "UpdatedBy",
                table: "sys_anonce",
                type: "bigint",
                nullable: true,
                comment: "更新人ID",
                oldClrType: typeof(long),
                oldType: "bigint",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "UpdatedAt",
                table: "sys_anonce",
                type: "datetime2",
                nullable: false,
                comment: "更新时间",
                oldClrType: typeof(DateTime),
                oldType: "datetime2");

            migrationBuilder.AlterColumn<string>(
                name: "Type",
                table: "sys_anonce",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                comment: "公告类型 (关联字典 anonce_type)",
                oldClrType: typeof(string),
                oldType: "nvarchar(50)",
                oldMaxLength: 50);

            migrationBuilder.AlterColumn<string>(
                name: "Title",
                table: "sys_anonce",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: false,
                comment: "公告标题",
                oldClrType: typeof(string),
                oldType: "nvarchar(200)",
                oldMaxLength: 200);

            migrationBuilder.AlterColumn<string>(
                name: "Status",
                table: "sys_anonce",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                comment: "状态 (draft:草稿, published:已发布, revoked:已撤回)",
                oldClrType: typeof(string),
                oldType: "nvarchar(20)",
                oldMaxLength: 20);

            migrationBuilder.AlterColumn<DateTime>(
                name: "PublishTime",
                table: "sys_anonce",
                type: "datetime2",
                nullable: true,
                comment: "发布时间",
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Priority",
                table: "sys_anonce",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                comment: "优先级 (high, normal, low)",
                oldClrType: typeof(string),
                oldType: "nvarchar(20)",
                oldMaxLength: 20);

            migrationBuilder.AlterColumn<long>(
                name: "CreatedBy",
                table: "sys_anonce",
                type: "bigint",
                nullable: true,
                comment: "创建人ID",
                oldClrType: typeof(long),
                oldType: "bigint",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedAt",
                table: "sys_anonce",
                type: "datetime2",
                nullable: false,
                comment: "创建时间",
                oldClrType: typeof(DateTime),
                oldType: "datetime2");

            migrationBuilder.AlterColumn<string>(
                name: "Content",
                table: "sys_anonce",
                type: "nvarchar(max)",
                nullable: false,
                comment: "公告内容",
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AlterColumn<long>(
                name: "Id",
                table: "sys_anonce",
                type: "bigint",
                nullable: false,
                comment: "主键ID",
                oldClrType: typeof(long),
                oldType: "bigint")
                .Annotation("SqlServer:Identity", "1, 1")
                .OldAnnotation("SqlServer:Identity", "1, 1");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterTable(
                name: "sys_anonce",
                oldComment: "系统公告表");

            migrationBuilder.AlterColumn<long>(
                name: "UpdatedBy",
                table: "sys_anonce",
                type: "bigint",
                nullable: true,
                oldClrType: typeof(long),
                oldType: "bigint",
                oldNullable: true,
                oldComment: "更新人ID");

            migrationBuilder.AlterColumn<DateTime>(
                name: "UpdatedAt",
                table: "sys_anonce",
                type: "datetime2",
                nullable: false,
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldComment: "更新时间");

            migrationBuilder.AlterColumn<string>(
                name: "Type",
                table: "sys_anonce",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(50)",
                oldMaxLength: 50,
                oldComment: "公告类型 (关联字典 anonce_type)");

            migrationBuilder.AlterColumn<string>(
                name: "Title",
                table: "sys_anonce",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(200)",
                oldMaxLength: 200,
                oldComment: "公告标题");

            migrationBuilder.AlterColumn<string>(
                name: "Status",
                table: "sys_anonce",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(20)",
                oldMaxLength: 20,
                oldComment: "状态 (draft:草稿, published:已发布, revoked:已撤回)");

            migrationBuilder.AlterColumn<DateTime>(
                name: "PublishTime",
                table: "sys_anonce",
                type: "datetime2",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldNullable: true,
                oldComment: "发布时间");

            migrationBuilder.AlterColumn<string>(
                name: "Priority",
                table: "sys_anonce",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(20)",
                oldMaxLength: 20,
                oldComment: "优先级 (high, normal, low)");

            migrationBuilder.AlterColumn<long>(
                name: "CreatedBy",
                table: "sys_anonce",
                type: "bigint",
                nullable: true,
                oldClrType: typeof(long),
                oldType: "bigint",
                oldNullable: true,
                oldComment: "创建人ID");

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedAt",
                table: "sys_anonce",
                type: "datetime2",
                nullable: false,
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldComment: "创建时间");

            migrationBuilder.AlterColumn<string>(
                name: "Content",
                table: "sys_anonce",
                type: "nvarchar(max)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldComment: "公告内容");

            migrationBuilder.AlterColumn<long>(
                name: "Id",
                table: "sys_anonce",
                type: "bigint",
                nullable: false,
                oldClrType: typeof(long),
                oldType: "bigint",
                oldComment: "主键ID")
                .Annotation("SqlServer:Identity", "1, 1")
                .OldAnnotation("SqlServer:Identity", "1, 1");
        }
    }
}
