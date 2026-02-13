-- Add Chinese comments to all tables and columns (PostgreSQL)

-- api_category
COMMENT ON TABLE "api_category" IS 'API分类';
COMMENT ON COLUMN "api_category"."Id" IS '主键ID';
COMMENT ON COLUMN "api_category"."Name" IS '名称';
COMMENT ON COLUMN "api_category"."ParentId" IS '父级ID';
COMMENT ON COLUMN "api_category"."SortOrder" IS '排序';
COMMENT ON COLUMN "api_category"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "api_category"."CreatedBy" IS '创建人';
COMMENT ON COLUMN "api_category"."UrlPrefix" IS 'UrlPrefix';

-- api_definition
COMMENT ON TABLE "api_definition" IS 'API定义';
COMMENT ON COLUMN "api_definition"."Id" IS '主键ID';
COMMENT ON COLUMN "api_definition"."CategoryId" IS 'CategoryId';
COMMENT ON COLUMN "api_definition"."Name" IS '名称';
COMMENT ON COLUMN "api_definition"."Path" IS '路径';
COMMENT ON COLUMN "api_definition"."Method" IS 'Method';
COMMENT ON COLUMN "api_definition"."Description" IS '描述';
COMMENT ON COLUMN "api_definition"."FlowConfig" IS 'FlowConfig';
COMMENT ON COLUMN "api_definition"."IsPublished" IS 'IsPublished';
COMMENT ON COLUMN "api_definition"."RequiresAuth" IS 'RequiresAuth';
COMMENT ON COLUMN "api_definition"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "api_definition"."UpdatedAt" IS '更新时间';
COMMENT ON COLUMN "api_definition"."CreatedBy" IS '创建人';
COMMENT ON COLUMN "api_definition"."UpdatedBy" IS '更新人';
COMMENT ON COLUMN "api_definition"."ManageRoles" IS 'ManageRoles';
COMMENT ON COLUMN "api_definition"."ViewRoles" IS 'ViewRoles';
COMMENT ON COLUMN "api_definition"."CallRoles" IS 'CallRoles';

-- arch_attachment
COMMENT ON TABLE "arch_attachment" IS '档案附件';
COMMENT ON COLUMN "arch_attachment"."Id" IS '主键ID';
COMMENT ON COLUMN "arch_attachment"."ArchFileId" IS 'ArchFileId';
COMMENT ON COLUMN "arch_attachment"."FileId" IS '文件ID';
COMMENT ON COLUMN "arch_attachment"."FileName" IS '文件名';
COMMENT ON COLUMN "arch_attachment"."Extension" IS '扩展名';
COMMENT ON COLUMN "arch_attachment"."Size" IS 'Size';
COMMENT ON COLUMN "arch_attachment"."FilePath" IS '文件路径';
COMMENT ON COLUMN "arch_attachment"."CreatedAt" IS '创建时间';

-- arch_box
COMMENT ON TABLE "arch_box" IS '档案盒';
COMMENT ON COLUMN "arch_box"."Id" IS '主键ID';
COMMENT ON COLUMN "arch_box"."FondId" IS 'FondId';
COMMENT ON COLUMN "arch_box"."TypeId" IS '类型ID';
COMMENT ON COLUMN "arch_box"."BoxCode" IS 'BoxCode';
COMMENT ON COLUMN "arch_box"."Title" IS '标题';
COMMENT ON COLUMN "arch_box"."Year" IS 'Year';
COMMENT ON COLUMN "arch_box"."RetentionPeriod" IS 'RetentionPeriod';
COMMENT ON COLUMN "arch_box"."SecurityLevel" IS 'SecurityLevel';
COMMENT ON COLUMN "arch_box"."Location" IS 'Location';
COMMENT ON COLUMN "arch_box"."RFID" IS 'RFID';
COMMENT ON COLUMN "arch_box"."FileCount" IS 'FileCount';
COMMENT ON COLUMN "arch_box"."Remark" IS '备注';
COMMENT ON COLUMN "arch_box"."Status" IS '状态';
COMMENT ON COLUMN "arch_box"."CreatedAt" IS '创建时间';

-- arch_file
COMMENT ON TABLE "arch_file" IS '档案文件';
COMMENT ON COLUMN "arch_file"."Id" IS '主键ID';
COMMENT ON COLUMN "arch_file"."FondId" IS 'FondId';
COMMENT ON COLUMN "arch_file"."TypeId" IS '类型ID';
COMMENT ON COLUMN "arch_file"."BoxId" IS 'BoxId';
COMMENT ON COLUMN "arch_file"."ArchCode" IS 'ArchCode';
COMMENT ON COLUMN "arch_file"."Title" IS '标题';
COMMENT ON COLUMN "arch_file"."DocNumber" IS 'DocNumber';
COMMENT ON COLUMN "arch_file"."Author" IS 'Author';
COMMENT ON COLUMN "arch_file"."FileDate" IS 'FileDate';
COMMENT ON COLUMN "arch_file"."Year" IS 'Year';
COMMENT ON COLUMN "arch_file"."RetentionPeriod" IS 'RetentionPeriod';
COMMENT ON COLUMN "arch_file"."SecurityLevel" IS 'SecurityLevel';
COMMENT ON COLUMN "arch_file"."PageCount" IS 'PageCount';
COMMENT ON COLUMN "arch_file"."Status" IS '状态';
COMMENT ON COLUMN "arch_file"."Keywords" IS 'Keywords';
COMMENT ON COLUMN "arch_file"."Remark" IS '备注';
COMMENT ON COLUMN "arch_file"."SourceFileId" IS 'SourceFileId';
COMMENT ON COLUMN "arch_file"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "arch_file"."UpdatedAt" IS '更新时间';

-- arch_fond
COMMENT ON TABLE "arch_fond" IS '全宗';
COMMENT ON COLUMN "arch_fond"."Id" IS '主键ID';
COMMENT ON COLUMN "arch_fond"."Code" IS '代码';
COMMENT ON COLUMN "arch_fond"."Name" IS '名称';
COMMENT ON COLUMN "arch_fond"."Description" IS '描述';
COMMENT ON COLUMN "arch_fond"."SortOrder" IS '排序';
COMMENT ON COLUMN "arch_fond"."CreatedAt" IS '创建时间';

-- arch_type
COMMENT ON TABLE "arch_type" IS '档案分类';
COMMENT ON COLUMN "arch_type"."Id" IS '主键ID';
COMMENT ON COLUMN "arch_type"."ParentId" IS '父级ID';
COMMENT ON COLUMN "arch_type"."Code" IS '代码';
COMMENT ON COLUMN "arch_type"."Name" IS '名称';
COMMENT ON COLUMN "arch_type"."SortOrder" IS '排序';

-- bigview_project
COMMENT ON TABLE "bigview_project" IS '大屏项目';
COMMENT ON COLUMN "bigview_project"."id" IS '主键ID';
COMMENT ON COLUMN "bigview_project"."project_name" IS 'project_name';
COMMENT ON COLUMN "bigview_project"."state" IS '状态 [-1未发布,1发布]';
COMMENT ON COLUMN "bigview_project"."create_time" IS '创建时间';
COMMENT ON COLUMN "bigview_project"."create_by" IS '创建人';
COMMENT ON COLUMN "bigview_project"."is_delete" IS '是否删除';
COMMENT ON COLUMN "bigview_project"."index_image" IS 'index_image';
COMMENT ON COLUMN "bigview_project"."content" IS '内容';
COMMENT ON COLUMN "bigview_project"."remarks" IS '备注';

-- contract_attachment
COMMENT ON TABLE "contract_attachment" IS '合同附件';
COMMENT ON COLUMN "contract_attachment"."Id" IS '主键ID';
COMMENT ON COLUMN "contract_attachment"."contract_id" IS 'contract_id';
COMMENT ON COLUMN "contract_attachment"."file_name" IS '文件名';
COMMENT ON COLUMN "contract_attachment"."file_path" IS '文件路径';
COMMENT ON COLUMN "contract_attachment"."size" IS 'size';
COMMENT ON COLUMN "contract_attachment"."upload_date" IS 'upload_date';

-- contract_contact
COMMENT ON TABLE "contract_contact" IS '合同联系人';
COMMENT ON COLUMN "contract_contact"."Id" IS '主键ID';
COMMENT ON COLUMN "contract_contact"."contract_id" IS 'contract_id';
COMMENT ON COLUMN "contract_contact"."name" IS '名称';
COMMENT ON COLUMN "contract_contact"."role" IS 'role';
COMMENT ON COLUMN "contract_contact"."phone" IS '电话';
COMMENT ON COLUMN "contract_contact"."email" IS '邮箱';

-- contract_invoice
COMMENT ON TABLE "contract_invoice" IS '合同发票';
COMMENT ON COLUMN "contract_invoice"."Id" IS '主键ID';
COMMENT ON COLUMN "contract_invoice"."contract_id" IS 'contract_id';
COMMENT ON COLUMN "contract_invoice"."invoice_no" IS 'invoice_no';
COMMENT ON COLUMN "contract_invoice"."invoice_date" IS 'invoice_date';
COMMENT ON COLUMN "contract_invoice"."amount" IS 'amount';
COMMENT ON COLUMN "contract_invoice"."type" IS '类型';
COMMENT ON COLUMN "contract_invoice"."status" IS 'status';
COMMENT ON COLUMN "contract_invoice"."attachment_file_name" IS 'attachment_file_name';
COMMENT ON COLUMN "contract_invoice"."attachment_file_path" IS 'attachment_file_path';
COMMENT ON COLUMN "contract_invoice"."direction" IS 'direction';

-- contract_knowledge_category
COMMENT ON TABLE "contract_knowledge_category" IS '合同知识分类';
COMMENT ON COLUMN "contract_knowledge_category"."Id" IS '主键ID';
COMMENT ON COLUMN "contract_knowledge_category"."name" IS '名称';
COMMENT ON COLUMN "contract_knowledge_category"."parent_id" IS '父级ID';
COMMENT ON COLUMN "contract_knowledge_category"."sort_order" IS 'sort_order';
COMMENT ON COLUMN "contract_knowledge_category"."created_at" IS 'created_at';

-- contract_knowledge_file
COMMENT ON TABLE "contract_knowledge_file" IS '合同知识文件';
COMMENT ON COLUMN "contract_knowledge_file"."Id" IS '主键ID';
COMMENT ON COLUMN "contract_knowledge_file"."category_id" IS 'category_id';
COMMENT ON COLUMN "contract_knowledge_file"."name" IS '名称';
COMMENT ON COLUMN "contract_knowledge_file"."type" IS '类型';
COMMENT ON COLUMN "contract_knowledge_file"."file_path" IS '文件路径';
COMMENT ON COLUMN "contract_knowledge_file"."size" IS 'size';
COMMENT ON COLUMN "contract_knowledge_file"."uploader" IS 'uploader';
COMMENT ON COLUMN "contract_knowledge_file"."upload_time" IS 'upload_time';
COMMENT ON COLUMN "contract_knowledge_file"."content_type" IS 'content_type';

-- contract_main
COMMENT ON TABLE "contract_main" IS '合同主表';
COMMENT ON COLUMN "contract_main"."Id" IS '主键ID';
COMMENT ON COLUMN "contract_main"."contract_no" IS 'contract_no';
COMMENT ON COLUMN "contract_main"."contract_name" IS 'contract_name';
COMMENT ON COLUMN "contract_main"."type" IS '类型';
COMMENT ON COLUMN "contract_main"."partner_name" IS 'partner_name';
COMMENT ON COLUMN "contract_main"."sign_date" IS 'sign_date';
COMMENT ON COLUMN "contract_main"."start_date" IS 'start_date';
COMMENT ON COLUMN "contract_main"."end_date" IS 'end_date';
COMMENT ON COLUMN "contract_main"."manager" IS 'manager';
COMMENT ON COLUMN "contract_main"."total_amount" IS 'total_amount';
COMMENT ON COLUMN "contract_main"."paid_amount" IS 'paid_amount';
COMMENT ON COLUMN "contract_main"."invoiced_amount" IS 'invoiced_amount';
COMMENT ON COLUMN "contract_main"."progress" IS 'progress';
COMMENT ON COLUMN "contract_main"."currency" IS 'currency';
COMMENT ON COLUMN "contract_main"."payment_method" IS 'payment_method';
COMMENT ON COLUMN "contract_main"."tax_id" IS 'tax_id';
COMMENT ON COLUMN "contract_main"."status" IS 'status';
COMMENT ON COLUMN "contract_main"."description" IS '描述';
COMMENT ON COLUMN "contract_main"."latest_transaction_date" IS 'latest_transaction_date';
COMMENT ON COLUMN "contract_main"."files" IS 'files';
COMMENT ON COLUMN "contract_main"."created_at" IS 'created_at';
COMMENT ON COLUMN "contract_main"."updated_at" IS 'updated_at';
COMMENT ON COLUMN "contract_main"."lifecycle_status" IS 'lifecycle_status';
COMMENT ON COLUMN "contract_main"."pricing_type" IS 'pricing_type';

-- contract_payment_plan
COMMENT ON TABLE "contract_payment_plan" IS '合同付款计划';
COMMENT ON COLUMN "contract_payment_plan"."Id" IS '主键ID';
COMMENT ON COLUMN "contract_payment_plan"."contract_id" IS 'contract_id';
COMMENT ON COLUMN "contract_payment_plan"."phase" IS 'phase';
COMMENT ON COLUMN "contract_payment_plan"."due_date" IS 'due_date';
COMMENT ON COLUMN "contract_payment_plan"."amount" IS 'amount';
COMMENT ON COLUMN "contract_payment_plan"."condition" IS 'condition';
COMMENT ON COLUMN "contract_payment_plan"."status" IS 'status';

-- contract_payment_record
COMMENT ON TABLE "contract_payment_record" IS '合同付款记录';
COMMENT ON COLUMN "contract_payment_record"."Id" IS '主键ID';
COMMENT ON COLUMN "contract_payment_record"."contract_id" IS 'contract_id';
COMMENT ON COLUMN "contract_payment_record"."payment_date" IS 'payment_date';
COMMENT ON COLUMN "contract_payment_record"."amount" IS 'amount';
COMMENT ON COLUMN "contract_payment_record"."method" IS 'method';
COMMENT ON COLUMN "contract_payment_record"."operator" IS 'operator';
COMMENT ON COLUMN "contract_payment_record"."remark" IS 'remark';
COMMENT ON COLUMN "contract_payment_record"."type" IS '类型';
COMMENT ON COLUMN "contract_payment_record"."voucher_file_name" IS 'voucher_file_name';
COMMENT ON COLUMN "contract_payment_record"."voucher_file_path" IS 'voucher_file_path';

-- contract_relation
COMMENT ON TABLE "contract_relation" IS '合同关联';
COMMENT ON COLUMN "contract_relation"."Id" IS '主键ID';
COMMENT ON COLUMN "contract_relation"."contract_id" IS 'contract_id';
COMMENT ON COLUMN "contract_relation"."related_contract_id" IS 'related_contract_id';
COMMENT ON COLUMN "contract_relation"."created_at" IS 'created_at';

-- contract_stat
COMMENT ON TABLE "contract_stat" IS '合同统计';
COMMENT ON COLUMN "contract_stat"."Id" IS '主键ID';
COMMENT ON COLUMN "contract_stat"."period_type" IS 'period_type';
COMMENT ON COLUMN "contract_stat"."period_key" IS 'period_key';
COMMENT ON COLUMN "contract_stat"."stat_date" IS 'stat_date';
COMMENT ON COLUMN "contract_stat"."total_contracts" IS 'total_contracts';
COMMENT ON COLUMN "contract_stat"."total_amount" IS 'total_amount';
COMMENT ON COLUMN "contract_stat"."received_amount" IS 'received_amount';
COMMENT ON COLUMN "contract_stat"."invoiced_amount" IS 'invoiced_amount';
COMMENT ON COLUMN "contract_stat"."pending_invoice_amount" IS 'pending_invoice_amount';
COMMENT ON COLUMN "contract_stat"."sales_count" IS 'sales_count';
COMMENT ON COLUMN "contract_stat"."purchase_count" IS 'purchase_count';
COMMENT ON COLUMN "contract_stat"."created_at" IS 'created_at';
COMMENT ON COLUMN "contract_stat"."amount_completion_rate" IS 'amount_completion_rate';
COMMENT ON COLUMN "contract_stat"."received_rate" IS 'received_rate';
COMMENT ON COLUMN "contract_stat"."total_contracts_growth" IS 'total_contracts_growth';

-- contract_template
COMMENT ON TABLE "contract_template" IS '合同模板';
COMMENT ON COLUMN "contract_template"."Id" IS '主键ID';
COMMENT ON COLUMN "contract_template"."name" IS '名称';
COMMENT ON COLUMN "contract_template"."type" IS '类型';
COMMENT ON COLUMN "contract_template"."description" IS '描述';
COMMENT ON COLUMN "contract_template"."file_path" IS '文件路径';
COMMENT ON COLUMN "contract_template"."file_name" IS '文件名';
COMMENT ON COLUMN "contract_template"."status" IS 'status';
COMMENT ON COLUMN "contract_template"."created_at" IS 'created_at';
COMMENT ON COLUMN "contract_template"."updated_at" IS 'updated_at';

-- data_source_connection
COMMENT ON TABLE "data_source_connection" IS '数据源连接';
COMMENT ON COLUMN "data_source_connection"."Id" IS '主键ID';
COMMENT ON COLUMN "data_source_connection"."Name" IS '名称';
COMMENT ON COLUMN "data_source_connection"."Type" IS '类型';
COMMENT ON COLUMN "data_source_connection"."Host" IS 'Host';
COMMENT ON COLUMN "data_source_connection"."Port" IS 'Port';
COMMENT ON COLUMN "data_source_connection"."User" IS 'User';
COMMENT ON COLUMN "data_source_connection"."Password" IS '密码';
COMMENT ON COLUMN "data_source_connection"."Database" IS 'Database';
COMMENT ON COLUMN "data_source_connection"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "data_source_connection"."UpdatedAt" IS '更新时间';

-- frm_category
COMMENT ON TABLE "frm_category" IS '表单分类';
COMMENT ON COLUMN "frm_category"."Id" IS '主键ID';
COMMENT ON COLUMN "frm_category"."Name" IS '名称';
COMMENT ON COLUMN "frm_category"."ParentId" IS '父级ID';
COMMENT ON COLUMN "frm_category"."SortOrder" IS '排序';
COMMENT ON COLUMN "frm_category"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "frm_category"."CreatedBy" IS '创建人';

-- frm_data
COMMENT ON TABLE "frm_data" IS '表单数据';
COMMENT ON COLUMN "frm_data"."id" IS '主键ID';
COMMENT ON COLUMN "frm_data"."form_id" IS 'form_id';
COMMENT ON COLUMN "frm_data"."data" IS 'data';
COMMENT ON COLUMN "frm_data"."submitted_at" IS 'submitted_at';
COMMENT ON COLUMN "frm_data"."submitted_by" IS 'submitted_by';

-- frm_definition
COMMENT ON TABLE "frm_definition" IS '表单定义';
COMMENT ON COLUMN "frm_definition"."Id" IS '主键ID';
COMMENT ON COLUMN "frm_definition"."CategoryId" IS 'CategoryId';
COMMENT ON COLUMN "frm_definition"."Name" IS '名称';
COMMENT ON COLUMN "frm_definition"."Code" IS '代码';
COMMENT ON COLUMN "frm_definition"."Description" IS '描述';
COMMENT ON COLUMN "frm_definition"."FormItems" IS 'FormItems';
COMMENT ON COLUMN "frm_definition"."IsPublished" IS 'IsPublished';
COMMENT ON COLUMN "frm_definition"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "frm_definition"."UpdatedAt" IS '更新时间';
COMMENT ON COLUMN "frm_definition"."CreatedBy" IS '创建人';
COMMENT ON COLUMN "frm_definition"."UpdatedBy" IS '更新人';
COMMENT ON COLUMN "frm_definition"."RequiresLogin" IS 'RequiresLogin';
COMMENT ON COLUMN "frm_definition"."LimitOnePerUser" IS 'LimitOnePerUser';
COMMENT ON COLUMN "frm_definition"."FillRoleIds" IS 'FillRoleIds';
COMMENT ON COLUMN "frm_definition"."ManageRoleIds" IS 'ManageRoleIds';
COMMENT ON COLUMN "frm_definition"."ViewRoleIds" IS 'ViewRoleIds';

-- kb_file
COMMENT ON TABLE "kb_file" IS '知识库文件';
COMMENT ON COLUMN "kb_file"."Id" IS '主键ID';
COMMENT ON COLUMN "kb_file"."KbId" IS 'KbId';
COMMENT ON COLUMN "kb_file"."Name" IS '名称';
COMMENT ON COLUMN "kb_file"."Size" IS 'Size';
COMMENT ON COLUMN "kb_file"."Extension" IS '扩展名';
COMMENT ON COLUMN "kb_file"."Path" IS '路径';
COMMENT ON COLUMN "kb_file"."Status" IS '状态';
COMMENT ON COLUMN "kb_file"."UploadTime" IS 'UploadTime';
COMMENT ON COLUMN "kb_file"."IsFolder" IS 'IsFolder';
COMMENT ON COLUMN "kb_file"."ParentId" IS '父级ID';

-- kb_info
COMMENT ON TABLE "kb_info" IS '知识库信息';
COMMENT ON COLUMN "kb_info"."Id" IS '主键ID';
COMMENT ON COLUMN "kb_info"."Name" IS '名称';
COMMENT ON COLUMN "kb_info"."Description" IS '描述';
COMMENT ON COLUMN "kb_info"."Category" IS 'Category';
COMMENT ON COLUMN "kb_info"."Type" IS '类型';
COMMENT ON COLUMN "kb_info"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "kb_info"."UpdatedAt" IS '更新时间';
COMMENT ON COLUMN "kb_info"."CreatedBy" IS '创建人';
COMMENT ON COLUMN "kb_info"."SortOrder" IS '排序';

-- kb_node_source
COMMENT ON TABLE "kb_node_source" IS '知识库节点源';
COMMENT ON COLUMN "kb_node_source"."Id" IS '主键ID';
COMMENT ON COLUMN "kb_node_source"."NodeId" IS 'NodeId';
COMMENT ON COLUMN "kb_node_source"."FileId" IS '文件ID';
COMMENT ON COLUMN "kb_node_source"."Page" IS 'Page';
COMMENT ON COLUMN "kb_node_source"."Description" IS '描述';

-- kb_qa_history
COMMENT ON TABLE "kb_qa_history" IS '知识库问答历史';
COMMENT ON COLUMN "kb_qa_history"."Id" IS '主键ID';
COMMENT ON COLUMN "kb_qa_history"."KbId" IS 'KbId';
COMMENT ON COLUMN "kb_qa_history"."UserId" IS '用户ID';
COMMENT ON COLUMN "kb_qa_history"."Question" IS 'Question';
COMMENT ON COLUMN "kb_qa_history"."Answer" IS 'Answer';
COMMENT ON COLUMN "kb_qa_history"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "kb_qa_history"."SourcesJson" IS 'SourcesJson';

-- page_categories
COMMENT ON TABLE "page_categories" IS '页面分类';
COMMENT ON COLUMN "page_categories"."Id" IS '主键ID';
COMMENT ON COLUMN "page_categories"."Name" IS '名称';
COMMENT ON COLUMN "page_categories"."ParentId" IS '父级ID';
COMMENT ON COLUMN "page_categories"."SortOrder" IS '排序';

-- page_definitions
COMMENT ON TABLE "page_definitions" IS '页面定义';
COMMENT ON COLUMN "page_definitions"."Id" IS '主键ID';
COMMENT ON COLUMN "page_definitions"."Name" IS '名称';
COMMENT ON COLUMN "page_definitions"."CategoryId" IS 'CategoryId';
COMMENT ON COLUMN "page_definitions"."Code" IS '代码';
COMMENT ON COLUMN "page_definitions"."Config" IS 'Config';
COMMENT ON COLUMN "page_definitions"."ApiBindings" IS 'ApiBindings';
COMMENT ON COLUMN "page_definitions"."Description" IS '描述';
COMMENT ON COLUMN "page_definitions"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "page_definitions"."UpdatedAt" IS '更新时间';

-- pdm_ebom_documents
COMMENT ON TABLE "pdm_ebom_documents" IS 'PDM EBOM文档';
COMMENT ON COLUMN "pdm_ebom_documents"."id" IS '主键ID';
COMMENT ON COLUMN "pdm_ebom_documents"."ebom_item_id" IS 'ebom_item_id';
COMMENT ON COLUMN "pdm_ebom_documents"."name" IS '名称';
COMMENT ON COLUMN "pdm_ebom_documents"."path" IS '路径';
COMMENT ON COLUMN "pdm_ebom_documents"."file_type" IS '文件类型';
COMMENT ON COLUMN "pdm_ebom_documents"."size" IS 'size';
COMMENT ON COLUMN "pdm_ebom_documents"."uploaded_at" IS 'uploaded_at';
COMMENT ON COLUMN "pdm_ebom_documents"."uploaded_by" IS 'uploaded_by';

-- pdm_ebom_items
COMMENT ON TABLE "pdm_ebom_items" IS 'PDM EBOM物料';
COMMENT ON COLUMN "pdm_ebom_items"."id" IS '主键ID';
COMMENT ON COLUMN "pdm_ebom_items"."name" IS '名称';
COMMENT ON COLUMN "pdm_ebom_items"."version" IS 'version';
COMMENT ON COLUMN "pdm_ebom_items"."status" IS 'status';
COMMENT ON COLUMN "pdm_ebom_items"."designer" IS 'designer';
COMMENT ON COLUMN "pdm_ebom_items"."spec" IS 'spec';
COMMENT ON COLUMN "pdm_ebom_items"."unit" IS 'unit';
COMMENT ON COLUMN "pdm_ebom_items"."is_leaf" IS 'is_leaf';
COMMENT ON COLUMN "pdm_ebom_items"."created_at" IS 'created_at';
COMMENT ON COLUMN "pdm_ebom_items"."updated_at" IS 'updated_at';
COMMENT ON COLUMN "pdm_ebom_items"."product_type" IS 'product_type';

-- pdm_ebom_structure
COMMENT ON TABLE "pdm_ebom_structure" IS 'PDM EBOM结构';
COMMENT ON COLUMN "pdm_ebom_structure"."id" IS '主键ID';
COMMENT ON COLUMN "pdm_ebom_structure"."parent_id" IS '父级ID';
COMMENT ON COLUMN "pdm_ebom_structure"."child_id" IS 'child_id';
COMMENT ON COLUMN "pdm_ebom_structure"."quantity" IS 'quantity';
COMMENT ON COLUMN "pdm_ebom_structure"."sort_order" IS 'sort_order';
COMMENT ON COLUMN "pdm_ebom_structure"."created_at" IS 'created_at';
COMMENT ON COLUMN "pdm_ebom_structure"."child_version" IS 'child_version';

-- project_attachments
COMMENT ON TABLE "project_attachments" IS '项目附件';
COMMENT ON COLUMN "project_attachments"."id" IS '主键ID';
COMMENT ON COLUMN "project_attachments"."taskId" IS 'taskId';
COMMENT ON COLUMN "project_attachments"."project_code" IS 'project_code';
COMMENT ON COLUMN "project_attachments"."name" IS '名称';
COMMENT ON COLUMN "project_attachments"."url" IS '链接';
COMMENT ON COLUMN "project_attachments"."type" IS '类型';
COMMENT ON COLUMN "project_attachments"."uploadDate" IS 'uploadDate';

-- project_info
COMMENT ON TABLE "project_info" IS '项目信息';
COMMENT ON COLUMN "project_info"."code" IS '代码';
COMMENT ON COLUMN "project_info"."name" IS '名称';
COMMENT ON COLUMN "project_info"."type" IS '类型';
COMMENT ON COLUMN "project_info"."description" IS '描述';
COMMENT ON COLUMN "project_info"."manager" IS 'manager';
COMMENT ON COLUMN "project_info"."planned_start_date" IS 'planned_start_date';
COMMENT ON COLUMN "project_info"."planned_end_date" IS 'planned_end_date';

-- project_members
COMMENT ON TABLE "project_members" IS '项目成员';
COMMENT ON COLUMN "project_members"."id" IS '主键ID';
COMMENT ON COLUMN "project_members"."project_code" IS 'project_code';
COMMENT ON COLUMN "project_members"."username" IS 'username';
COMMENT ON COLUMN "project_members"."role" IS 'role';
COMMENT ON COLUMN "project_members"."joined_at" IS 'joined_at';

-- project_phases
COMMENT ON TABLE "project_phases" IS '项目阶段';
COMMENT ON COLUMN "project_phases"."id" IS '主键ID';
COMMENT ON COLUMN "project_phases"."project_code" IS 'project_code';
COMMENT ON COLUMN "project_phases"."name" IS '名称';
COMMENT ON COLUMN "project_phases"."color" IS 'color';

-- project_swimlanes
COMMENT ON TABLE "project_swimlanes" IS '项目泳道';
COMMENT ON COLUMN "project_swimlanes"."id" IS '主键ID';
COMMENT ON COLUMN "project_swimlanes"."project_code" IS 'project_code';
COMMENT ON COLUMN "project_swimlanes"."name" IS '名称';
COMMENT ON COLUMN "project_swimlanes"."color" IS 'color';

-- project_task_dependencies
COMMENT ON TABLE "project_task_dependencies" IS '项目任务依赖';
COMMENT ON COLUMN "project_task_dependencies"."id" IS '主键ID';
COMMENT ON COLUMN "project_task_dependencies"."taskId" IS 'taskId';
COMMENT ON COLUMN "project_task_dependencies"."dependencyId" IS 'dependencyId';
COMMENT ON COLUMN "project_task_dependencies"."project_code" IS 'project_code';
COMMENT ON COLUMN "project_task_dependencies"."type" IS '类型';
COMMENT ON COLUMN "project_task_dependencies"."sourcePort" IS 'sourcePort';
COMMENT ON COLUMN "project_task_dependencies"."targetPort" IS 'targetPort';
COMMENT ON COLUMN "project_task_dependencies"."controlPoints" IS 'controlPoints';
COMMENT ON COLUMN "project_task_dependencies"."controlPointCount" IS 'controlPointCount';

-- project_tasks
COMMENT ON TABLE "project_tasks" IS '项目任务';
COMMENT ON COLUMN "project_tasks"."id" IS '主键ID';
COMMENT ON COLUMN "project_tasks"."project_code" IS 'project_code';
COMMENT ON COLUMN "project_tasks"."name" IS '名称';
COMMENT ON COLUMN "project_tasks"."phaseId" IS 'phaseId';
COMMENT ON COLUMN "project_tasks"."swimlaneId" IS 'swimlaneId';
COMMENT ON COLUMN "project_tasks"."status" IS 'status';
COMMENT ON COLUMN "project_tasks"."progress" IS 'progress';
COMMENT ON COLUMN "project_tasks"."owner" IS 'owner';
COMMENT ON COLUMN "project_tasks"."startDate" IS 'startDate';
COMMENT ON COLUMN "project_tasks"."endDate" IS 'endDate';
COMMENT ON COLUMN "project_tasks"."type" IS '类型';
COMMENT ON COLUMN "project_tasks"."description" IS '描述';
COMMENT ON COLUMN "project_tasks"."x" IS 'x';
COMMENT ON COLUMN "project_tasks"."y" IS 'y';
COMMENT ON COLUMN "project_tasks"."startColor" IS 'startColor';
COMMENT ON COLUMN "project_tasks"."endColor" IS 'endColor';
COMMENT ON COLUMN "project_tasks"."width" IS 'width';

-- sales_bid_analysis
COMMENT ON TABLE "sales_bid_analysis" IS '标书分析';
COMMENT ON COLUMN "sales_bid_analysis"."id" IS '主键ID';
COMMENT ON COLUMN "sales_bid_analysis"."bid_project_id" IS 'bid_project_id';
COMMENT ON COLUMN "sales_bid_analysis"."tender_type" IS 'tender_type';
COMMENT ON COLUMN "sales_bid_analysis"."deadline" IS 'deadline';
COMMENT ON COLUMN "sales_bid_analysis"."bid_bond" IS 'bid_bond';
COMMENT ON COLUMN "sales_bid_analysis"."budget" IS 'budget';
COMMENT ON COLUMN "sales_bid_analysis"."qualification" IS 'qualification';
COMMENT ON COLUMN "sales_bid_analysis"."created_at" IS 'created_at';
COMMENT ON COLUMN "sales_bid_analysis"."updated_at" IS 'updated_at';
COMMENT ON COLUMN "sales_bid_analysis"."file_name" IS '文件名';
COMMENT ON COLUMN "sales_bid_analysis"."file_url" IS 'file_url';
COMMENT ON COLUMN "sales_bid_analysis"."agency_name" IS 'agency_name';
COMMENT ON COLUMN "sales_bid_analysis"."bid_end_time" IS 'bid_end_time';
COMMENT ON COLUMN "sales_bid_analysis"."bid_start_time" IS 'bid_start_time';
COMMENT ON COLUMN "sales_bid_analysis"."contact_name" IS 'contact_name';
COMMENT ON COLUMN "sales_bid_analysis"."contact_phone" IS 'contact_phone';
COMMENT ON COLUMN "sales_bid_analysis"."open_bid_time" IS 'open_bid_time';
COMMENT ON COLUMN "sales_bid_analysis"."tender_start_time" IS 'tender_start_time';
COMMENT ON COLUMN "sales_bid_analysis"."publish_time" IS 'publish_time';

-- sales_bid_analysis_log
COMMENT ON TABLE "sales_bid_analysis_log" IS '标书分析日志';
COMMENT ON COLUMN "sales_bid_analysis_log"."id" IS '主键ID';
COMMENT ON COLUMN "sales_bid_analysis_log"."run_id" IS 'run_id';
COMMENT ON COLUMN "sales_bid_analysis_log"."bid_project_id" IS 'bid_project_id';
COMMENT ON COLUMN "sales_bid_analysis_log"."message" IS 'message';
COMMENT ON COLUMN "sales_bid_analysis_log"."created_at" IS 'created_at';

-- sales_bid_analysis_run
COMMENT ON TABLE "sales_bid_analysis_run" IS '标书分析运行';
COMMENT ON COLUMN "sales_bid_analysis_run"."id" IS '主键ID';
COMMENT ON COLUMN "sales_bid_analysis_run"."bid_project_id" IS 'bid_project_id';
COMMENT ON COLUMN "sales_bid_analysis_run"."status" IS 'status';
COMMENT ON COLUMN "sales_bid_analysis_run"."started_at" IS 'started_at';
COMMENT ON COLUMN "sales_bid_analysis_run"."finished_at" IS 'finished_at';
COMMENT ON COLUMN "sales_bid_analysis_run"."created_by" IS 'created_by';

-- sales_bid_chapter
COMMENT ON TABLE "sales_bid_chapter" IS '标书章节';
COMMENT ON COLUMN "sales_bid_chapter"."id" IS '主键ID';
COMMENT ON COLUMN "sales_bid_chapter"."analysis_id" IS 'analysis_id';
COMMENT ON COLUMN "sales_bid_chapter"."parent_id" IS '父级ID';
COMMENT ON COLUMN "sales_bid_chapter"."title" IS '标题';
COMMENT ON COLUMN "sales_bid_chapter"."chapter_type" IS 'chapter_type';
COMMENT ON COLUMN "sales_bid_chapter"."content" IS '内容';
COMMENT ON COLUMN "sales_bid_chapter"."analysis_result" IS 'analysis_result';
COMMENT ON COLUMN "sales_bid_chapter"."risk_level" IS 'risk_level';
COMMENT ON COLUMN "sales_bid_chapter"."is_veto" IS 'is_veto';
COMMENT ON COLUMN "sales_bid_chapter"."score_weight" IS 'score_weight';
COMMENT ON COLUMN "sales_bid_chapter"."sort_order" IS 'sort_order';
COMMENT ON COLUMN "sales_bid_chapter"."extractions_json" IS 'extractions_json';

-- sales_bid_project
COMMENT ON TABLE "sales_bid_project" IS '标书项目';
COMMENT ON COLUMN "sales_bid_project"."id" IS '主键ID';
COMMENT ON COLUMN "sales_bid_project"."code" IS '代码';
COMMENT ON COLUMN "sales_bid_project"."name" IS '名称';
COMMENT ON COLUMN "sales_bid_project"."customer" IS 'customer';
COMMENT ON COLUMN "sales_bid_project"."region" IS 'region';
COMMENT ON COLUMN "sales_bid_project"."type" IS '类型';
COMMENT ON COLUMN "sales_bid_project"."budget" IS 'budget';
COMMENT ON COLUMN "sales_bid_project"."bid_time" IS 'bid_time';
COMMENT ON COLUMN "sales_bid_project"."leader" IS 'leader';
COMMENT ON COLUMN "sales_bid_project"."status" IS 'status';
COMMENT ON COLUMN "sales_bid_project"."description" IS '描述';
COMMENT ON COLUMN "sales_bid_project"."created_at" IS 'created_at';
COMMENT ON COLUMN "sales_bid_project"."updated_at" IS 'updated_at';

-- sales_customer
COMMENT ON TABLE "sales_customer" IS '销售客户';
COMMENT ON COLUMN "sales_customer"."id" IS '主键ID';
COMMENT ON COLUMN "sales_customer"."name" IS '名称';
COMMENT ON COLUMN "sales_customer"."credit_code" IS 'credit_code';
COMMENT ON COLUMN "sales_customer"."industry" IS 'industry';
COMMENT ON COLUMN "sales_customer"."contact" IS 'contact';
COMMENT ON COLUMN "sales_customer"."phone" IS '电话';
COMMENT ON COLUMN "sales_customer"."email" IS '邮箱';
COMMENT ON COLUMN "sales_customer"."level" IS 'level';
COMMENT ON COLUMN "sales_customer"."status" IS 'status';
COMMENT ON COLUMN "sales_customer"."address" IS 'address';
COMMENT ON COLUMN "sales_customer"."source" IS 'source';
COMMENT ON COLUMN "sales_customer"."description" IS '描述';
COMMENT ON COLUMN "sales_customer"."owner" IS 'owner';
COMMENT ON COLUMN "sales_customer"."created_at" IS 'created_at';
COMMENT ON COLUMN "sales_customer"."updated_at" IS 'updated_at';
COMMENT ON COLUMN "sales_customer"."org_id" IS '组织ID';

-- sales_opportunity
COMMENT ON TABLE "sales_opportunity" IS '销售商机';
COMMENT ON COLUMN "sales_opportunity"."id" IS '主键ID';
COMMENT ON COLUMN "sales_opportunity"."title" IS '标题';
COMMENT ON COLUMN "sales_opportunity"."customer" IS 'customer';
COMMENT ON COLUMN "sales_opportunity"."customer_id" IS 'customer_id';
COMMENT ON COLUMN "sales_opportunity"."amount" IS 'amount';
COMMENT ON COLUMN "sales_opportunity"."stage" IS 'stage';
COMMENT ON COLUMN "sales_opportunity"."win_rate" IS 'win_rate';
COMMENT ON COLUMN "sales_opportunity"."owner" IS 'owner';
COMMENT ON COLUMN "sales_opportunity"."description" IS '描述';
COMMENT ON COLUMN "sales_opportunity"."estimated_close_date" IS 'estimated_close_date';
COMMENT ON COLUMN "sales_opportunity"."created_at" IS 'created_at';
COMMENT ON COLUMN "sales_opportunity"."updated_at" IS 'updated_at';

-- sales_process_rule
COMMENT ON TABLE "sales_process_rule" IS '销售流程规则';
COMMENT ON COLUMN "sales_process_rule"."id" IS '主键ID';
COMMENT ON COLUMN "sales_process_rule"."title" IS '标题';
COMMENT ON COLUMN "sales_process_rule"."content" IS '内容';
COMMENT ON COLUMN "sales_process_rule"."created_at" IS 'created_at';
COMMENT ON COLUMN "sales_process_rule"."org_id" IS '组织ID';

-- sales_product_doc
COMMENT ON TABLE "sales_product_doc" IS '销售产品文档';
COMMENT ON COLUMN "sales_product_doc"."id" IS '主键ID';
COMMENT ON COLUMN "sales_product_doc"."title" IS '标题';
COMMENT ON COLUMN "sales_product_doc"."size" IS 'size';
COMMENT ON COLUMN "sales_product_doc"."url" IS '链接';
COMMENT ON COLUMN "sales_product_doc"."upload_date" IS 'upload_date';
COMMENT ON COLUMN "sales_product_doc"."parent_id" IS '父级ID';
COMMENT ON COLUMN "sales_product_doc"."type" IS '类型';
COMMENT ON COLUMN "sales_product_doc"."org_id" IS '组织ID';

-- sales_registrations
COMMENT ON TABLE "sales_registrations" IS '销售登记';
COMMENT ON COLUMN "sales_registrations"."Id" IS '主键ID';
COMMENT ON COLUMN "sales_registrations"."ProjectName" IS 'ProjectName';
COMMENT ON COLUMN "sales_registrations"."CustomerName" IS 'CustomerName';
COMMENT ON COLUMN "sales_registrations"."Contact" IS 'Contact';
COMMENT ON COLUMN "sales_registrations"."Phone" IS '电话';
COMMENT ON COLUMN "sales_registrations"."Amount" IS 'Amount';
COMMENT ON COLUMN "sales_registrations"."Date" IS 'Date';
COMMENT ON COLUMN "sales_registrations"."Status" IS '状态';
COMMENT ON COLUMN "sales_registrations"."Owner" IS 'Owner';
COMMENT ON COLUMN "sales_registrations"."Remarks" IS 'Remarks';
COMMENT ON COLUMN "sales_registrations"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "sales_registrations"."UpdatedAt" IS '更新时间';
COMMENT ON COLUMN "sales_registrations"."OrgId" IS '组织ID';

-- sales_script
COMMENT ON TABLE "sales_script" IS '销售话术';
COMMENT ON COLUMN "sales_script"."id" IS '主键ID';
COMMENT ON COLUMN "sales_script"."title" IS '标题';
COMMENT ON COLUMN "sales_script"."content" IS '内容';
COMMENT ON COLUMN "sales_script"."category" IS 'category';
COMMENT ON COLUMN "sales_script"."created_at" IS 'created_at';
COMMENT ON COLUMN "sales_script"."description" IS '描述';
COMMENT ON COLUMN "sales_script"."org_id" IS '组织ID';

-- sales_target
COMMENT ON TABLE "sales_target" IS '销售目标';
COMMENT ON COLUMN "sales_target"."id" IS '主键ID';
COMMENT ON COLUMN "sales_target"."period" IS 'period';
COMMENT ON COLUMN "sales_target"."target_type" IS 'target_type';
COMMENT ON COLUMN "sales_target"."target_id" IS 'target_id';
COMMENT ON COLUMN "sales_target"."target_name" IS 'target_name';
COMMENT ON COLUMN "sales_target"."target_amount" IS 'target_amount';
COMMENT ON COLUMN "sales_target"."completed_amount" IS 'completed_amount';
COMMENT ON COLUMN "sales_target"."status" IS 'status';
COMMENT ON COLUMN "sales_target"."start_date" IS 'start_date';
COMMENT ON COLUMN "sales_target"."end_date" IS 'end_date';
COMMENT ON COLUMN "sales_target"."created_at" IS 'created_at';
COMMENT ON COLUMN "sales_target"."updated_at" IS 'updated_at';

-- sys_ai_generated_content
COMMENT ON TABLE "sys_ai_generated_content" IS 'AI生成内容';
COMMENT ON COLUMN "sys_ai_generated_content"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_ai_generated_content"."Type" IS '类型：greeting (问候语), slogan (标语)';
COMMENT ON COLUMN "sys_ai_generated_content"."Content" IS '内容';
COMMENT ON COLUMN "sys_ai_generated_content"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "sys_ai_generated_content"."CreatedBy" IS '创建人';
COMMENT ON COLUMN "sys_ai_generated_content"."IpAddress" IS 'IpAddress';

-- sys_anonce
COMMENT ON TABLE "sys_anonce" IS '系统公告';
COMMENT ON COLUMN "sys_anonce"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_anonce"."Title" IS '公告标题';
COMMENT ON COLUMN "sys_anonce"."Content" IS '公告内容';
COMMENT ON COLUMN "sys_anonce"."Type" IS '公告类型 (关联字典 anonce_type)';
COMMENT ON COLUMN "sys_anonce"."Status" IS '状态 (draft:草稿, published:已发布, revoked:已撤回)';
COMMENT ON COLUMN "sys_anonce"."PublishTime" IS '发布时间';
COMMENT ON COLUMN "sys_anonce"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "sys_anonce"."UpdatedAt" IS '更新时间';
COMMENT ON COLUMN "sys_anonce"."CreatedBy" IS '创建人ID';
COMMENT ON COLUMN "sys_anonce"."UpdatedBy" IS '更新人ID';
COMMENT ON COLUMN "sys_anonce"."Priority" IS '优先级 (high, normal, low)';

-- sys_audit_log
COMMENT ON TABLE "sys_audit_log" IS '审计日志';
COMMENT ON COLUMN "sys_audit_log"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_audit_log"."UserId" IS '用户ID';
COMMENT ON COLUMN "sys_audit_log"."UserName" IS 'UserName';
COMMENT ON COLUMN "sys_audit_log"."Action" IS 'Action';
COMMENT ON COLUMN "sys_audit_log"."Route" IS 'Route';
COMMENT ON COLUMN "sys_audit_log"."Method" IS 'Method';
COMMENT ON COLUMN "sys_audit_log"."IpAddress" IS 'IpAddress';
COMMENT ON COLUMN "sys_audit_log"."UserAgent" IS 'UserAgent';
COMMENT ON COLUMN "sys_audit_log"."Parameters" IS 'Parameters';
COMMENT ON COLUMN "sys_audit_log"."IsSuccess" IS 'IsSuccess';
COMMENT ON COLUMN "sys_audit_log"."ErrorMessage" IS 'ErrorMessage';
COMMENT ON COLUMN "sys_audit_log"."ExecutionDuration" IS 'ExecutionDuration';
COMMENT ON COLUMN "sys_audit_log"."CreatedAt" IS '创建时间';

-- sys_chat_conversation
COMMENT ON TABLE "sys_chat_conversation" IS '聊天会话';
COMMENT ON COLUMN "sys_chat_conversation"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_chat_conversation"."ConversationKey" IS 'ConversationKey';
COMMENT ON COLUMN "sys_chat_conversation"."Type" IS '0=Private, 1=Group, 2=System, 3=App';
COMMENT ON COLUMN "sys_chat_conversation"."User1Id" IS 'User1Id';
COMMENT ON COLUMN "sys_chat_conversation"."User2Id" IS 'User2Id';
COMMENT ON COLUMN "sys_chat_conversation"."RelatedId" IS '关联ID。 对于群组(Type=1)，此处存GroupId。 对于系统/应用(Type=2/3)，如果模块有ID则存ID；如果只有字符串代码(如 \"workflow\")，则此处存null，通过 ConversationKey 区分。';
COMMENT ON COLUMN "sys_chat_conversation"."Name" IS '名称';
COMMENT ON COLUMN "sys_chat_conversation"."Avatar" IS '头像';
COMMENT ON COLUMN "sys_chat_conversation"."LastMessageContent" IS 'LastMessageContent';
COMMENT ON COLUMN "sys_chat_conversation"."LastMessageType" IS 'LastMessageType';
COMMENT ON COLUMN "sys_chat_conversation"."LastMessageTime" IS 'LastMessageTime';
COMMENT ON COLUMN "sys_chat_conversation"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "sys_chat_conversation"."UpdatedAt" IS '更新时间';

-- sys_chat_message
COMMENT ON TABLE "sys_chat_message" IS '聊天消息';
COMMENT ON COLUMN "sys_chat_message"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_chat_message"."ConversationKey" IS 'ConversationKey';
COMMENT ON COLUMN "sys_chat_message"."SenderConnectionId" IS 'SenderConnectionId';
COMMENT ON COLUMN "sys_chat_message"."SenderUserId" IS 'SenderUserId';
COMMENT ON COLUMN "sys_chat_message"."SenderUserName" IS 'SenderUserName';
COMMENT ON COLUMN "sys_chat_message"."Type" IS '类型';
COMMENT ON COLUMN "sys_chat_message"."Content" IS '内容';
COMMENT ON COLUMN "sys_chat_message"."FileName" IS '文件名';
COMMENT ON COLUMN "sys_chat_message"."FileSize" IS '文件大小';
COMMENT ON COLUMN "sys_chat_message"."CreatedAt" IS '创建时间';

-- sys_config
COMMENT ON TABLE "sys_config" IS '系统配置';
COMMENT ON COLUMN "sys_config"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_config"."Category" IS 'Category';
COMMENT ON COLUMN "sys_config"."Key" IS 'Key';
COMMENT ON COLUMN "sys_config"."Value" IS 'Value';
COMMENT ON COLUMN "sys_config"."Description" IS '描述';
COMMENT ON COLUMN "sys_config"."IsSystem" IS 'IsSystem';
COMMENT ON COLUMN "sys_config"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "sys_config"."UpdatedAt" IS '更新时间';
COMMENT ON COLUMN "sys_config"."IsOverridable" IS 'IsOverridable';
COMMENT ON COLUMN "sys_config"."OrgId" IS '组织ID';
COMMENT ON COLUMN "sys_config"."Type" IS '类型';

-- sys_dept
COMMENT ON TABLE "sys_dept" IS '部门';
COMMENT ON COLUMN "sys_dept"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_dept"."ParentId" IS '父级ID';
COMMENT ON COLUMN "sys_dept"."Name" IS '名称';
COMMENT ON COLUMN "sys_dept"."Code" IS '代码';
COMMENT ON COLUMN "sys_dept"."Leader" IS 'Leader';
COMMENT ON COLUMN "sys_dept"."Phone" IS '电话';
COMMENT ON COLUMN "sys_dept"."Email" IS '邮箱';
COMMENT ON COLUMN "sys_dept"."SortOrder" IS '排序';
COMMENT ON COLUMN "sys_dept"."IsActive" IS 'IsActive';
COMMENT ON COLUMN "sys_dept"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "sys_dept"."UpdatedAt" IS '更新时间';
COMMENT ON COLUMN "sys_dept"."Type" IS '类型';
COMMENT ON COLUMN "sys_dept"."X" IS 'X';
COMMENT ON COLUMN "sys_dept"."Y" IS 'Y';

-- sys_dict_category
COMMENT ON TABLE "sys_dict_category" IS '字典分类';
COMMENT ON COLUMN "sys_dict_category"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_dict_category"."parent_id" IS '父级ID';
COMMENT ON COLUMN "sys_dict_category"."name" IS '名称';
COMMENT ON COLUMN "sys_dict_category"."code" IS '代码';
COMMENT ON COLUMN "sys_dict_category"."sort" IS 'sort';
COMMENT ON COLUMN "sys_dict_category"."remark" IS 'remark';
COMMENT ON COLUMN "sys_dict_category"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "sys_dict_category"."UpdatedAt" IS '更新时间';

-- sys_dict_data
COMMENT ON TABLE "sys_dict_data" IS '字典数据';
COMMENT ON COLUMN "sys_dict_data"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_dict_data"."dict_type_id" IS 'dict_type_id';
COMMENT ON COLUMN "sys_dict_data"."label" IS 'label';
COMMENT ON COLUMN "sys_dict_data"."value" IS 'value';
COMMENT ON COLUMN "sys_dict_data"."sort" IS 'sort';
COMMENT ON COLUMN "sys_dict_data"."status" IS 'status';
COMMENT ON COLUMN "sys_dict_data"."is_default" IS 'is_default';
COMMENT ON COLUMN "sys_dict_data"."css_class" IS 'css_class';
COMMENT ON COLUMN "sys_dict_data"."list_class" IS 'list_class';
COMMENT ON COLUMN "sys_dict_data"."remark" IS 'remark';
COMMENT ON COLUMN "sys_dict_data"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "sys_dict_data"."UpdatedAt" IS '更新时间';

-- sys_dict_type
COMMENT ON TABLE "sys_dict_type" IS '字典类型';
COMMENT ON COLUMN "sys_dict_type"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_dict_type"."category_id" IS 'category_id';
COMMENT ON COLUMN "sys_dict_type"."name" IS '名称';
COMMENT ON COLUMN "sys_dict_type"."code" IS '代码';
COMMENT ON COLUMN "sys_dict_type"."status" IS 'status';
COMMENT ON COLUMN "sys_dict_type"."remark" IS 'remark';
COMMENT ON COLUMN "sys_dict_type"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "sys_dict_type"."UpdatedAt" IS '更新时间';

-- sys_file
COMMENT ON TABLE "sys_file" IS '系统文件';
COMMENT ON COLUMN "sys_file"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_file"."Name" IS '名称';
COMMENT ON COLUMN "sys_file"."Extension" IS '扩展名';
COMMENT ON COLUMN "sys_file"."Size" IS 'Size';
COMMENT ON COLUMN "sys_file"."IsFolder" IS 'IsFolder';
COMMENT ON COLUMN "sys_file"."FilePath" IS '文件路径';
COMMENT ON COLUMN "sys_file"."ContentType" IS 'ContentType';
COMMENT ON COLUMN "sys_file"."ParentId" IS '父级ID';
COMMENT ON COLUMN "sys_file"."OwnerId" IS 'OwnerId';
COMMENT ON COLUMN "sys_file"."DeptId" IS '部门ID';
COMMENT ON COLUMN "sys_file"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "sys_file"."UpdatedAt" IS '更新时间';
COMMENT ON COLUMN "sys_file"."IsPublic" IS 'IsPublic';

-- sys_file_share
COMMENT ON TABLE "sys_file_share" IS '文件分享';
COMMENT ON COLUMN "sys_file_share"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_file_share"."FileId" IS '文件ID';
COMMENT ON COLUMN "sys_file_share"."SharedByUserId" IS 'SharedByUserId';
COMMENT ON COLUMN "sys_file_share"."SharedToUserId" IS 'SharedToUserId';
COMMENT ON COLUMN "sys_file_share"."Permission" IS 'Permission';
COMMENT ON COLUMN "sys_file_share"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "sys_file_share"."ExpirationTime" IS 'ExpirationTime';
COMMENT ON COLUMN "sys_file_share"."Token" IS '令牌';

-- sys_org_registration
COMMENT ON TABLE "sys_org_registration" IS '组织注册';
COMMENT ON COLUMN "sys_org_registration"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_org_registration"."OrgName" IS 'OrgName';
COMMENT ON COLUMN "sys_org_registration"."OrgShortName" IS 'OrgShortName';
COMMENT ON COLUMN "sys_org_registration"."OrgAbbr" IS 'OrgAbbr';
COMMENT ON COLUMN "sys_org_registration"."LicenseCode" IS 'LicenseCode';
COMMENT ON COLUMN "sys_org_registration"."LicenseFileUrl" IS 'LicenseFileUrl';
COMMENT ON COLUMN "sys_org_registration"."AuthLetterFileUrl" IS 'AuthLetterFileUrl';
COMMENT ON COLUMN "sys_org_registration"."ContactName" IS 'ContactName';
COMMENT ON COLUMN "sys_org_registration"."ContactPhone" IS 'ContactPhone';
COMMENT ON COLUMN "sys_org_registration"."ContactEmail" IS 'ContactEmail';
COMMENT ON COLUMN "sys_org_registration"."AdminUsername" IS 'AdminUsername';
COMMENT ON COLUMN "sys_org_registration"."AdminPassword" IS 'AdminPassword';
COMMENT ON COLUMN "sys_org_registration"."Status" IS '状态';
COMMENT ON COLUMN "sys_org_registration"."RejectReason" IS 'RejectReason';
COMMENT ON COLUMN "sys_org_registration"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "sys_org_registration"."UpdatedAt" IS '更新时间';

-- sys_permission
COMMENT ON TABLE "sys_permission" IS '权限';
COMMENT ON COLUMN "sys_permission"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_permission"."ParentId" IS '父级ID';
COMMENT ON COLUMN "sys_permission"."Name" IS '名称';
COMMENT ON COLUMN "sys_permission"."Code" IS '代码';
COMMENT ON COLUMN "sys_permission"."Type" IS '类型';
COMMENT ON COLUMN "sys_permission"."Path" IS '路径';
COMMENT ON COLUMN "sys_permission"."Component" IS '组件';
COMMENT ON COLUMN "sys_permission"."Query" IS 'Query';
COMMENT ON COLUMN "sys_permission"."Icon" IS '图标';
COMMENT ON COLUMN "sys_permission"."SortOrder" IS '排序';
COMMENT ON COLUMN "sys_permission"."IsVisible" IS 'IsVisible';
COMMENT ON COLUMN "sys_permission"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "sys_permission"."UpdatedAt" IS '更新时间';

-- sys_post
COMMENT ON TABLE "sys_post" IS '岗位';
COMMENT ON COLUMN "sys_post"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_post"."Code" IS '代码';
COMMENT ON COLUMN "sys_post"."Name" IS '名称';
COMMENT ON COLUMN "sys_post"."SortOrder" IS '排序';
COMMENT ON COLUMN "sys_post"."IsActive" IS 'IsActive';
COMMENT ON COLUMN "sys_post"."Remark" IS '备注';
COMMENT ON COLUMN "sys_post"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "sys_post"."UpdatedAt" IS '更新时间';
COMMENT ON COLUMN "sys_post"."DeptId" IS '部门ID';

-- sys_role
COMMENT ON TABLE "sys_role" IS '角色';
COMMENT ON COLUMN "sys_role"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_role"."Name" IS '名称';
COMMENT ON COLUMN "sys_role"."Code" IS '代码';
COMMENT ON COLUMN "sys_role"."Description" IS '描述';
COMMENT ON COLUMN "sys_role"."IsSystem" IS 'IsSystem';
COMMENT ON COLUMN "sys_role"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "sys_role"."UpdatedAt" IS '更新时间';
COMMENT ON COLUMN "sys_role"."DeptId" IS '部门ID';

-- sys_role_inheritance
COMMENT ON TABLE "sys_role_inheritance" IS '角色继承';
COMMENT ON COLUMN "sys_role_inheritance"."ParentRoleId" IS 'ParentRoleId';
COMMENT ON COLUMN "sys_role_inheritance"."ChildRoleId" IS 'ChildRoleId';

-- sys_role_permission
COMMENT ON TABLE "sys_role_permission" IS '角色权限';
COMMENT ON COLUMN "sys_role_permission"."RoleId" IS '角色ID';
COMMENT ON COLUMN "sys_role_permission"."PermissionId" IS 'PermissionId';
COMMENT ON COLUMN "sys_role_permission"."CreatedAt" IS '创建时间';

-- sys_user
COMMENT ON TABLE "sys_user" IS '用户';
COMMENT ON COLUMN "sys_user"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_user"."Username" IS 'Username';
COMMENT ON COLUMN "sys_user"."Password" IS '密码';
COMMENT ON COLUMN "sys_user"."Nickname" IS 'Nickname';
COMMENT ON COLUMN "sys_user"."Email" IS '邮箱';
COMMENT ON COLUMN "sys_user"."Phone" IS '电话';
COMMENT ON COLUMN "sys_user"."IsActive" IS 'IsActive';
COMMENT ON COLUMN "sys_user"."CreatedAt" IS '创建时间';
COMMENT ON COLUMN "sys_user"."LastLoginAt" IS 'LastLoginAt';
COMMENT ON COLUMN "sys_user"."Avatar" IS '头像';
COMMENT ON COLUMN "sys_user"."DeptId" IS '部门ID';
COMMENT ON COLUMN "sys_user"."Status" IS '状态';
COMMENT ON COLUMN "sys_user"."CurrentOrgId" IS 'CurrentOrgId';

-- sys_user_post
COMMENT ON TABLE "sys_user_post" IS '用户岗位';
COMMENT ON COLUMN "sys_user_post"."UserId" IS '用户ID';
COMMENT ON COLUMN "sys_user_post"."PostId" IS '岗位ID';
COMMENT ON COLUMN "sys_user_post"."DeptId" IS '部门ID';

-- sys_user_role
COMMENT ON TABLE "sys_user_role" IS '用户角色';
COMMENT ON COLUMN "sys_user_role"."UserId" IS '用户ID';
COMMENT ON COLUMN "sys_user_role"."RoleId" IS '角色ID';
COMMENT ON COLUMN "sys_user_role"."CreatedAt" IS '创建时间';

-- sys_db_migration
COMMENT ON TABLE "sys_db_migration" IS '数据库迁移记录';
COMMENT ON COLUMN "sys_db_migration"."Id" IS '主键ID';
COMMENT ON COLUMN "sys_db_migration"."FileName" IS '迁移文件名';
COMMENT ON COLUMN "sys_db_migration"."ExecutedAt" IS '执行时间';
COMMENT ON COLUMN "sys_db_migration"."Status" IS '状态';
COMMENT ON COLUMN "sys_db_migration"."ErrorMessage" IS '错误信息';

