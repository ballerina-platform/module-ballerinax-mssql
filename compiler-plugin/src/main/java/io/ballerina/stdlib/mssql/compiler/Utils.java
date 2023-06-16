/*
 * Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package io.ballerina.stdlib.mssql.compiler;

import io.ballerina.compiler.api.symbols.ModuleSymbol;
import io.ballerina.compiler.api.symbols.Symbol;
import io.ballerina.compiler.api.symbols.SymbolKind;
import io.ballerina.compiler.api.symbols.TypeDescKind;
import io.ballerina.compiler.api.symbols.TypeReferenceTypeSymbol;
import io.ballerina.compiler.api.symbols.TypeSymbol;
import io.ballerina.compiler.api.symbols.UnionTypeSymbol;
import io.ballerina.compiler.syntax.tree.BasicLiteralNode;
import io.ballerina.compiler.syntax.tree.ChildNodeEntry;
import io.ballerina.compiler.syntax.tree.ExpressionNode;
import io.ballerina.compiler.syntax.tree.MappingConstructorExpressionNode;
import io.ballerina.compiler.syntax.tree.MappingFieldNode;
import io.ballerina.compiler.syntax.tree.ModulePartNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.NodeList;
import io.ballerina.compiler.syntax.tree.NonTerminalNode;
import io.ballerina.compiler.syntax.tree.RecordFieldNode;
import io.ballerina.compiler.syntax.tree.RecordFieldWithDefaultValueNode;
import io.ballerina.compiler.syntax.tree.RecordTypeDescriptorNode;
import io.ballerina.compiler.syntax.tree.SeparatedNodeList;
import io.ballerina.compiler.syntax.tree.SimpleNameReferenceNode;
import io.ballerina.compiler.syntax.tree.SpecificFieldNode;
import io.ballerina.compiler.syntax.tree.SpreadFieldNode;
import io.ballerina.compiler.syntax.tree.TypeDefinitionNode;
import io.ballerina.compiler.syntax.tree.TypedBindingPatternNode;
import io.ballerina.compiler.syntax.tree.UnaryExpressionNode;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticFactory;
import io.ballerina.tools.diagnostics.DiagnosticInfo;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;
import io.ballerina.tools.diagnostics.Location;

import java.util.List;
import java.util.Optional;

import static io.ballerina.stdlib.mssql.compiler.Constants.UNNECESSARY_CHARS_REGEX;
import static io.ballerina.stdlib.mssql.compiler.MSSQLDiagnosticsCode.MSSQL_101;
import static io.ballerina.stdlib.mssql.compiler.MSSQLDiagnosticsCode.MSSQL_102;

/**
 * Utils class.
 */
public class Utils {

    private Utils() {
    }

    public static boolean hasCompilationErrors(SyntaxNodeAnalysisContext ctx) {
        for (Diagnostic diagnostic : ctx.compilation().diagnosticResult().diagnostics()) {
            if (diagnostic.diagnosticInfo().severity() == DiagnosticSeverity.ERROR) {
                return true;
            }
        }
        return false;
    }

    public static boolean isMSSQLClientObject(SyntaxNodeAnalysisContext ctx, ExpressionNode node) {
        Optional<TypeSymbol> objectType = ctx.semanticModel().typeOf(node);
        if (objectType.isEmpty()) {
            return false;
        }
        if (objectType.get().typeKind() == TypeDescKind.UNION) {
            return ((UnionTypeSymbol) objectType.get()).memberTypeDescriptors().stream()
                    .filter(typeDescriptor -> typeDescriptor instanceof TypeReferenceTypeSymbol)
                    .map(typeReferenceTypeSymbol -> (TypeReferenceTypeSymbol) typeReferenceTypeSymbol)
                    .anyMatch(Utils::isMSSQLClientObject);
        }
        if (objectType.get() instanceof TypeReferenceTypeSymbol) {
            return isMSSQLClientObject(((TypeReferenceTypeSymbol) objectType.get()));
        }
        return false;
    }

    public static boolean isMSSQLClientObject(TypeReferenceTypeSymbol typeReference) {
        Optional<ModuleSymbol> optionalModuleSymbol = typeReference.getModule();
        if (optionalModuleSymbol.isEmpty()) {
            return false;
        }
        ModuleSymbol module = optionalModuleSymbol.get();
        if (!(module.id().orgName().equals(Constants.BALLERINAX) && module.id().moduleName().equals(Constants.MSSQL))) {
            return false;
        }
        String objectName = typeReference.definition().getName().get();
        return objectName.equals(Constants.Client.CLIENT);
    }

    public static void  validateOptionConfig(SyntaxNodeAnalysisContext ctx, MappingConstructorExpressionNode options) {
        for (MappingFieldNode field: options.fields()) {
            if (field instanceof SpecificFieldNode) {
                SpecificFieldNode specificFieldNode = ((SpecificFieldNode) field);
                validateOptions(ctx, specificFieldNode.fieldName().toString().trim().
                        replaceAll(UNNECESSARY_CHARS_REGEX, ""), specificFieldNode.valueExpr().get());
            } else if (field instanceof SpreadFieldNode) {
                NodeList<Node> recordFields = Utils.getSpreadFieldType(ctx, ((SpreadFieldNode) field));
                for (Node recordField : recordFields) {
                    if (recordField instanceof RecordFieldWithDefaultValueNode) {
                        RecordFieldWithDefaultValueNode fieldWithDefaultValueNode =
                                (RecordFieldWithDefaultValueNode) recordField;
                        validateOptions(ctx, fieldWithDefaultValueNode.fieldName().toString().
                                        trim().replaceAll(UNNECESSARY_CHARS_REGEX, ""),
                                fieldWithDefaultValueNode.expression());
                    }
                }
            }
        }
    }

    public static void validateOptions(SyntaxNodeAnalysisContext ctx, String name, ExpressionNode valueNode) {
        switch (name) {
            case Constants.Options.LOGIN_TIMEOUT:
            case Constants.Options.SOCKET_TIMEOUT:
                float fieldVal = Float.parseFloat(getTerminalNodeValue(valueNode, "0"));
                if (fieldVal < 0) {
                    DiagnosticInfo diagnosticInfo = new DiagnosticInfo(MSSQL_101.getCode(), MSSQL_101.getMessage(),
                            MSSQL_101.getSeverity());
                    ctx.reportDiagnostic(
                            DiagnosticFactory.createDiagnostic(diagnosticInfo, valueNode.location()));
                }
                break;
            case Constants.Options.QUERY_TIMEOUT:
                float queryTimeout = Float.parseFloat(getTerminalNodeValue(valueNode, "0"));
                if (queryTimeout < -1) {
                    DiagnosticInfo diagnosticInfo = new DiagnosticInfo(MSSQL_102.getCode(), MSSQL_102.getMessage(),
                            MSSQL_102.getSeverity());
                    ctx.reportDiagnostic(
                            DiagnosticFactory.createDiagnostic(diagnosticInfo, valueNode.location()));
                }
                break;
            default:
                // Can ignore all other fields
        }
    }

    public static NodeList<Node> getSpreadFieldType(SyntaxNodeAnalysisContext ctx, SpreadFieldNode spreadFieldNode) {
        List<Symbol> symbols = ctx.semanticModel().moduleSymbols();
        Object[] entries = spreadFieldNode.valueExpr().childEntries().toArray();
        ModulePartNode modulePartNode = ctx.syntaxTree().rootNode();
        ChildNodeEntry type = Utils.getVariableType(symbols, entries, modulePartNode);
        RecordTypeDescriptorNode typeDescriptor = Utils.getFirstSpreadFieldRecordTypeDescriptorNode(symbols,
                type, modulePartNode);
        typeDescriptor = Utils.getEndSpreadFieldRecordType(symbols, entries, modulePartNode,
                typeDescriptor);
        return typeDescriptor.fields();
    }

    public static ChildNodeEntry getVariableType(List<Symbol> symbols, Object[] entries,
                                                 ModulePartNode modulePartNode) {
        for (Symbol symbol : symbols) {
            if (!symbol.kind().equals(SymbolKind.VARIABLE)) {
                continue;
            }
            Optional<String> symbolName = symbol.getName();
            Optional<Node> childNodeEntry = ((ChildNodeEntry) entries[0]).node();
            if (symbolName.isPresent() && childNodeEntry.isPresent() &&
                    symbolName.get().equals(childNodeEntry.get().toString())) {
                Optional<Location> location = symbol.getLocation();
                if (location.isPresent()) {
                    Location loc = location.get();
                    NonTerminalNode node = modulePartNode.findNode(loc.textRange());
                    if (node instanceof TypedBindingPatternNode) {
                        TypedBindingPatternNode typedBindingPatternNode = (TypedBindingPatternNode) node;
                        return  (ChildNodeEntry) typedBindingPatternNode.childEntries().toArray()[0];
                    }
                }
            }
        }
        return null;
    }

    public static RecordTypeDescriptorNode getFirstSpreadFieldRecordTypeDescriptorNode(List<Symbol> symbols,
                                                                                       ChildNodeEntry type,
                                                                                       ModulePartNode modulePartNode) {
        if (type != null && type.node().isPresent()) {
            for (Symbol symbol : symbols) {
                if (!symbol.kind().equals(SymbolKind.TYPE_DEFINITION)) {
                    continue;
                }
                if (symbol.getName().isPresent() &&
                        symbol.getName().get().equals(type.node().get().toString().trim())) {
                    Optional<Location> loc = symbol.getLocation();
                    if (loc.isPresent()) {
                        Location location = loc.get();
                        Node node = modulePartNode.findNode(location.textRange());
                        if (node instanceof TypeDefinitionNode) {
                            TypeDefinitionNode typeDefinitionNode = (TypeDefinitionNode) node;
                            return  (RecordTypeDescriptorNode) typeDefinitionNode.typeDescriptor();
                        }
                    }
                }
            }
        }
        return null;
    }

    public static RecordTypeDescriptorNode getEndSpreadFieldRecordType(List<Symbol> symbols, Object[] entries,
                                                                       ModulePartNode modulePartNode,
                                                                       RecordTypeDescriptorNode typeDescriptor) {
        if (typeDescriptor != null) {
            for (int i = 1; i < entries.length; i++) {
                String childNodeEntry = ((ChildNodeEntry) entries[i]).node().get().toString();
                NodeList<Node> recordFields = typeDescriptor.fields();
                if (childNodeEntry.equals(".")) {
                    continue;
                }
                for (Node recordField : recordFields) {
                    String fieldName;
                    Node fieldType;
                    if (recordField instanceof RecordFieldWithDefaultValueNode) {
                        RecordFieldWithDefaultValueNode fieldWithDefaultValueNode =
                                (RecordFieldWithDefaultValueNode) recordField;
                        fieldName = fieldWithDefaultValueNode.fieldName().text().trim();
                        fieldType = fieldWithDefaultValueNode.typeName();
                    } else {
                        RecordFieldNode fieldNode = (RecordFieldNode) recordField;
                        fieldName = fieldNode.fieldName().text().trim();
                        fieldType = fieldNode.typeName();
                    }
                    if (fieldName.equals(childNodeEntry.trim())) {
                        if (fieldType instanceof SimpleNameReferenceNode) {
                            SimpleNameReferenceNode nameReferenceNode = (SimpleNameReferenceNode) fieldType;
                            for (Symbol symbol : symbols) {
                                if (!symbol.kind().equals(SymbolKind.TYPE_DEFINITION)) {
                                    continue;
                                }
                                if (symbol.getName().isPresent() &&
                                        symbol.getName().get().equals(nameReferenceNode.name().text().trim())) {
                                    Optional<Location> loc = symbol.getLocation();
                                    if (loc.isPresent()) {
                                        Location location = loc.get();
                                        Node node = modulePartNode.findNode(location.textRange());
                                        if (node instanceof TypeDefinitionNode) {
                                            TypeDefinitionNode typeDefinitionNode = (TypeDefinitionNode) node;
                                            typeDescriptor = (RecordTypeDescriptorNode) typeDefinitionNode.
                                                    typeDescriptor();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return typeDescriptor;
    }

    public static String getTerminalNodeValue(Node valueNode, String defaultValue) {
        String value = defaultValue;
        if (valueNode instanceof BasicLiteralNode) {
            value = ((BasicLiteralNode) valueNode).literalToken().text();
        } else if (valueNode instanceof UnaryExpressionNode) {
            UnaryExpressionNode unaryExpressionNode = (UnaryExpressionNode) valueNode;
            value = unaryExpressionNode.unaryOperator() +
                    ((BasicLiteralNode) unaryExpressionNode.expression()).literalToken().text();
        }
        // Currently, we cannot process values from variables, this needs code flow analysis
        return value.replaceAll(UNNECESSARY_CHARS_REGEX, "");
    }
}
