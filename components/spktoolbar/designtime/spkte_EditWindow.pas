unit spkte_EditWindow;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, {DesignIntf, DesignEditors,} StdCtrls, ImgList, ComCtrls, ToolWin,
  ActnList, Menus, ComponentEditors, PropEdits,
  SpkToolbar, spkt_Tab, spkt_Pane, spkt_BaseItem, spkt_Buttons, spkt_Types, spkt_Checkboxes;

type TCreateItemFunc = function(Pane : TSpkPane) : TSpkBaseItem;

type
  TfrmEditWindow = class(TForm)
    aAddCheckbox: TAction;
    aAddRadioButton: TAction;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    tvStructure: TTreeView;
    ilTreeImages: TImageList;
    tbToolBar: TToolBar;
    tbAddTab: TToolButton;
    ilActionImages: TImageList;
    tbRemoveTab: TToolButton;
    ToolButton3: TToolButton;
    tbAddPane: TToolButton;
    tbRemovePane: TToolButton;
    ActionList1: TActionList;
    aAddTab: TAction;
    aRemoveTab: TAction;
    aAddPane: TAction;
    aRemovePane: TAction;
    ToolButton6: TToolButton;
    aMoveUp: TAction;
    aMoveDown: TAction;
    tbMoveUp: TToolButton;
    tbMoveDown: TToolButton;
    ToolButton9: TToolButton;
    tbAddItem: TToolButton;
    tbRemoveItem: TToolButton;
    pmAddItem: TPopupMenu;
    SpkLargeButton1: TMenuItem;
    aAddLargeButton: TAction;
    aRemoveItem: TAction;
    aAddSmallButton: TAction;
    SpkSmallButton1: TMenuItem;
    pmStructure: TPopupMenu;
    Addtab1: TMenuItem;
    Removetab1: TMenuItem;
    N1: TMenuItem;
    Addpane1: TMenuItem;
    Removepane1: TMenuItem;
    N2: TMenuItem;
    Additem1: TMenuItem;
    SpkLargeButton2: TMenuItem;
    SpkSmallButton2: TMenuItem;
    Removeitem1: TMenuItem;
    N3: TMenuItem;
    Moveup1: TMenuItem;
    Movedown1: TMenuItem;
    procedure tvStructureChange(Sender: TObject; Node: TTreeNode);
    procedure aAddTabExecute(Sender: TObject);
    procedure aRemoveTabExecute(Sender: TObject);
    procedure aAddPaneExecute(Sender: TObject);
    procedure aRemovePaneExecute(Sender: TObject);
    procedure aMoveUpExecute(Sender: TObject);
    procedure aMoveDownExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure aAddLargeButtonExecute(Sender: TObject);
    procedure aRemoveItemExecute(Sender: TObject);
    procedure aAddSmallButtonExecute(Sender: TObject);
    procedure aAddCheckboxExecute(Sender: TObject);
    procedure aAddRadioButtonExecute(Sender: TObject);
    procedure tvStructureDeletion(Sender:TObject; Node:TTreeNode);
    procedure tvStructureKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure tvStructureEdited(Sender: TObject; Node: TTreeNode;
      var S: string);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  protected
    FToolbar: TSpkToolbar;
    FDesigner: TComponentEditorDesigner;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure CheckActionsAvailability;

    procedure AddItem(ItemClass: TSpkBaseItemClass);
    function GetItemCaption(Item : TSpkBaseItem) : string;
    procedure SetItemCaption(Item : TSpkBaseItem; const Value : String);

    procedure DoRemoveTab;
    procedure DoRemovePane;
    procedure DoRemoveItem;

    function CheckValidTabNode(Node : TTreeNode) : boolean;
    function CheckValidPaneNode(Node : TTreeNode) : boolean;
    function CheckValidItemNode(Node : TTreeNode) : boolean;
  public
    { Public declarations }
    function ValidateTreeData : boolean;
    procedure BuildTreeData;
    procedure RefreshNames;

    procedure SetData(AToolbar : TSpkToolbar; ADesigner: TComponentEditorDesigner);

    property Toolbar : TSpkToolbar read FToolbar;
  end;

var
  frmEditWindow: TfrmEditWindow;

implementation

{$R *.lfm}

{ TfrmEditWindow }

procedure TfrmEditWindow.aAddPaneExecute(Sender: TObject);

var Obj : TObject;
    Node : TTreeNode;
    NewNode : TTreeNode;
    Tab : TSpkTab;
    Pane : TSpkPane;
begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;
if FDesigner.PropertyEditorHook = nil then
   Exit;

Node:=tvStructure.Selected;
if Node = nil then
   raise Exception.create('TfrmEditWindow.aAddPaneExecute: Brak zaznaczonego obiektu!');
if Node.Data = nil then
   raise Exception.create('TfrmEditWindow.aAddPaneExecute: Uszkodzona struktura drzewa!');

Obj:=TObject(Node.Data);
if Obj is TSpkTab then
   begin
   Tab:=TSpkTab(Obj);
   Pane:=TSpkPane.Create(FToolbar.Owner);
   Pane.Parent:=FToolbar;
   Pane.Name := FDesigner.CreateUniqueComponentName(Pane.ClassName);
   Tab.Panes.AddItem(Pane);
   NewNode:=tvStructure.Items.AddChild(Node, Pane.Caption);
   NewNode.Data:=Pane;
   NewNode.ImageIndex:=1;
   NewNode.SelectedIndex:=1;
   NewNode.Selected:=true;
   CheckActionsAvailability;
   end else
if Obj is TSpkPane then
   begin
   if not(CheckValidPaneNode(Node)) then
      raise exception.create('TfrmEditWindow.aAddPaneExecute: Uszkodzona struktura drzewa!');

   Tab:=TSpkTab(Node.Parent.Data);
   Pane:=TSpkPane.Create(FToolbar.Owner);
   Pane.Parent:=FToolbar;
   Pane.Name:=FDesigner.CreateUniqueComponentName(Pane.ClassName);
   Tab.Panes.AddItem(Pane);
   NewNode:=tvStructure.Items.AddChild(Node.Parent, Pane.Caption);
   NewNode.Data:=Pane;
   NewNode.ImageIndex:=1;
   NewNode.SelectedIndex:=1;
   NewNode.Selected:=true;
   CheckActionsAvailability;

   end else
if Obj is TSpkBaseItem then
   begin
   if not(CheckValidItemNode(Node)) then
      raise exception.create('TfrmEditWindow.aAddPaneExecute: Uszkodzona struktura drzewa!');

   Tab:=TSpkTab(Node.Parent.Parent.Data);
   Pane:=TSpkPane.Create(FToolbar.Owner);
   Pane.Parent:=FToolbar;
   Pane.Name:=FDesigner.CreateUniqueComponentName(Pane.ClassName);
   Tab.Panes.AddItem(Pane);
   NewNode:=tvStructure.Items.AddChild(Node.Parent.Parent, Pane.Caption);
   NewNode.Data:=Pane;
   NewNode.ImageIndex:=1;
   NewNode.SelectedIndex:=1;
   NewNode.Selected:=true;
   CheckActionsAvailability;
   end else
       raise exception.create('TfrmEditWindow.aAddPaneExecute: Nieprawid�owy obiekt podwieszony pod ga��zi�!');
   FDesigner.PropertyEditorHook.PersistentAdded(Pane,True);
   FDesigner.Modified;
end;

procedure TfrmEditWindow.aAddSmallButtonExecute(Sender: TObject);
begin
  AddItem(TSpkSmallButton);
end;

procedure TfrmEditWindow.aAddLargeButtonExecute(Sender: TObject);
begin
  AddItem(TSpkLargeButton);
end;

procedure TfrmEditWindow.aAddCheckboxExecute(Sender: TObject);
begin
  AddItem(TSpkCheckbox);
end;

procedure TfrmEditWindow.aAddRadioButtonExecute(Sender: TObject);
begin
  AddItem(TSpkRadioButton);
end;

procedure TfrmEditWindow.aAddTabExecute(Sender: TObject);

var Node : TTreeNode;
    Tab : TSpkTab;

begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;
if FDesigner.PropertyEditorHook = nil then
   Exit;

Tab:=TSpkTab.Create(FToolbar.Owner);
Tab.Parent:=FToolbar;
FToolbar.Tabs.AddItem(Tab);
Tab.Name:=FDesigner.CreateUniqueComponentName(Tab.ClassName);
Node:=tvStructure.Items.AddChild(nil, Tab.Caption);
Node.Data:=Tab;
Node.ImageIndex:=0;
Node.SelectedIndex:=0;
Node.Selected:=true;
CheckActionsAvailability;

FDesigner.PropertyEditorHook.PersistentAdded(Tab,True);
FDesigner.Modified;
end;

procedure TfrmEditWindow.AddItem(ItemClass: TSpkBaseItemClass);

var Node : TTreeNode;
    Obj : TObject;
    Pane: TSpkPane;
    Item: TSpkBaseItem;
    NewNode: TTreeNode;
    s: string;
begin
if (FToolbar=nil) or (FDesigner=nil) then
  Exit;
if FDesigner.PropertyEditorHook = nil then
  Exit;

Node:=tvStructure.Selected;
if Node = nil then
   raise Exception.Create('TfrmEditWindow.AddItem: Brak zaznaczonego obiektu!');
if Node.Data = nil then
   raise Exception.Create('TfrmEditWindow.AddItem: Uszkodzona struktura drzewa!');

Obj:=TObject(Node.Data);
if Obj is TSpkPane then
   begin
   Pane:=TSpkPane(Obj);
   Item:=ItemClass.Create(FToolbar.Owner);
   Item.Parent:=FToolbar;
   Pane.Items.AddItem(Item);
   Item.Name:=FDesigner.CreateUniqueComponentName(Item.ClassName);
   s:=GetItemCaption(Item);
   NewNode:=tvStructure.Items.AddChild(Node, s);
   NewNode.Data:=Item;
   NewNode.ImageIndex:=2;
   NewNode.SelectedIndex:=2;
   NewNode.Selected:=true;
   CheckActionsAvailability;
   end else
if Obj is TSpkBaseItem then
   begin
   if not(CheckValidItemNode(Node)) then
      raise exception.create('TfrmEditWindow.AddItem: Uszkodzona struktura drzewa!');

   Pane:=TSpkPane(Node.Parent.Data);
   Item:=ItemClass.Create(FToolbar.Owner);
   Item.Parent:=FToolbar;
   Pane.Items.AddItem(Item);
   Item.Name:=FDesigner.CreateUniqueComponentName(Item.ClassName);
   s:=GetItemCaption(Item);
   NewNode:=tvStructure.Items.AddChild(Node.Parent, s);
   NewNode.Data:=Item;
   NewNode.ImageIndex:=2;
   NewNode.SelectedIndex:=2;
   NewNode.Selected:=true;
   CheckActionsAvailability;
   end else
       raise exception.create('TfrmEditWindow.AddItem: Nieprawid�owy obiekt podwieszony pod ga��zi�!');
   FDesigner.PropertyEditorHook.PersistentAdded(Item,True);
   FDesigner.Modified;
end;

procedure TfrmEditWindow.aMoveDownExecute(Sender: TObject);

var Node : TTreeNode;
    Tab : TSpkTab;
    Pane : TSpkPane;
    Obj : TObject;
    index: Integer;
  Item: TSpkBaseItem;

begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

Node:=tvStructure.Selected;
if Node = nil then
   raise exception.create('TfrmEditWindow.aMoveDownExecute: Nie zaznaczono obiektu do przesuni�cia!');
if Node.Data = nil then
   raise exception.create('TfrmEditWindow.aMoveDownExecute: Uszkodzona struktura drzewa!');

Obj:=TObject(Node.Data);

if Obj is TSpkTab then
   begin
   if not(CheckValidTabNode(Node)) then
      raise exception.create('TfrmEditWindow.aMoveDownExecute: Uszkodzona struktura drzewa!');

   Tab:=TSpkTab(Node.Data);
   index:=FToolbar.Tabs.IndexOf(Tab);
   if (index=-1) then
      raise exception.create('TfrmEditWindow.aMoveDownExecute: Uszkodzona struktura drzewa!');
   if (index=FToolbar.Tabs.Count-1) then
      raise exception.create('TfrmEditWindow.aMoveDownExecute: Nie mo�na przesun�� w d� ostatniego elementu!');

   FToolbar.Tabs.Exchange(index,index+1);
   FToolbar.TabIndex:=index+1;

   Node.GetNextSibling.MoveTo(Node, naInsert);
   Node.Selected:=true;
   CheckActionsAvailability;
   end else
if Obj is TSpkPane then
   begin
   if not(CheckValidPaneNode(Node)) then
      raise exception.create('TfrmEditWindow.aMoveDownExecute: Uszkodzona struktura drzewa!');

   Pane:=TSpkPane(Node.Data);
   Tab:=TSpkTab(Node.Parent.Data);

   index:=Tab.Panes.IndexOf(Pane);
   if (index=-1) then
      raise exception.create('TfrmEditWindow.aMoveDownExecute: Uszkodzona struktura drzewa!');
   if (index=Tab.Panes.Count-1) then
      raise exception.create('TfrmEditWindow.aMoveDownExecute: Nie mo�na przesun�� w d� ostatniego elementu!');

   Tab.Panes.Exchange(index, index+1);

   Node.GetNextSibling.MoveTo(Node, naInsert);
   Node.Selected:=true;
   CheckActionsAvailability;
   end else
if Obj is TSpkBaseItem then
   begin
   if not(CheckValidItemNode(Node)) then
      raise exception.create('TfrmEditWindow.aMoveDown.Execute: Uszkodzona struktura drzewa!');

   Item:=TSpkBaseItem(Node.Data);
   Pane:=TSpkPane(Node.Parent.Data);

   index:=Pane.Items.IndexOf(Item);
   if (index=-1) then
      raise exception.create('TfrmEditWindow.aMoveDownExecute: Uszkodzona struktura drzewa!');
   if (index=Pane.Items.Count-1) then
      raise exception.create('TfrmEditWindow.aMoveDownExecute: Nie mo�na przesun�� w d� ostatniego elementu!');

   Pane.Items.Exchange(index, index+1);

   Node.GetNextSibling.MoveTo(Node, naInsert);
   Node.Selected:=true;
   CheckActionsAvailability;
   end else
       raise exception.create('TfrmEditWindow.aMoveDownExecute: Nieprawid�owy obiekt podwieszony pod ga��zi�!');
end;

procedure TfrmEditWindow.aMoveUpExecute(Sender: TObject);

var Node : TTreeNode;
    Tab : TSpkTab;
    Pane : TSpkPane;
    Obj : TObject;
    index: Integer;
  Item: TSpkBaseItem;

begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

Node:=tvStructure.Selected;
if Node = nil then
   raise exception.create('TfrmEditWindow.aMoveUpExecute: Nie zaznaczono obiektu do przesuni�cia!');
if Node.Data = nil then
   raise exception.create('TfrmEditWindow.aMoveUpExecute: Uszkodzona struktura drzewa!');

Obj:=TObject(Node.Data);

if Obj is TSpkTab then
   begin
   if not(CheckValidTabNode(Node)) then
      raise exception.create('TfrmEditWindow.aMoveUpExecute: Uszkodzona struktura drzewa!');

   Tab:=TSpkTab(Node.Data);
   index:=FToolbar.Tabs.IndexOf(Tab);
   if (index=-1) then
      raise exception.create('TfrmEditWindow.aMoveUpExecute: Uszkodzona struktura drzewa!');
   if (index=0) then
      raise exception.create('TfrmEditWindow.aMoveUpExecute: Nie mo�na przesun�� do g�ry pierwszego elementu!');

   FToolbar.Tabs.Exchange(index,index-1);
   FToolbar.TabIndex:=index-1;

   Node.MoveTo(Node.getPrevSibling, naInsert);
   Node.Selected:=true;
   CheckActionsAvailability;
   end else
if Obj is TSpkPane then
   begin
   if not(CheckValidPaneNode(Node)) then
      raise exception.create('TfrmEditWindow.aMoveUpExecute: Uszkodzona struktura drzewa!');

   Pane:=TSpkPane(Node.Data);
   Tab:=TSpkTab(Node.Parent.Data);

   index:=Tab.Panes.IndexOf(Pane);
   if (index=-1) then
      raise exception.create('TfrmEditWindow.aMoveUpExecute: Uszkodzona struktura drzewa!');
   if (index=0) then
      raise exception.create('TfrmEditWindow.aMoveUpExecute: Nie mo�na przesun�� do g�ry pierwszego elementu!');

   Tab.Panes.Exchange(index, index-1);

   Node.MoveTo(Node.GetPrevSibling, naInsert);
   Node.Selected:=true;
   CheckActionsAvailability;
   end else
if Obj is TSpkBaseItem then
   begin
   if not(CheckValidItemNode(Node)) then
      raise exception.create('TfrmEditWindow.aMoveUpExecute: Uszkodzona struktura drzewa!');

   Item:=TSpkBaseItem(Node.Data);
   Pane:=TSpkPane(Node.Parent.Data);

   index:=Pane.Items.IndexOf(Item);
   if (index=-1) then
      raise exception.create('TfrmEditWindow.aMoveUpExecute: Uszkodzona struktura drzewa!');
   if (index=0) then
      raise exception.create('TfrmEditWindow.aMoveUpExecute: Nie mo�na przesun�� do g�ry pierwszego elementu!');

   Pane.Items.Exchange(index, index-1);

   Node.MoveTo(Node.GetPrevSibling, naInsert);
   Node.Selected:=true;
   CheckActionsAvailability;
   end else
       raise exception.create('TfrmEditWindow.aMoveUpExecute: Nieprawid�owy obiekt podwieszony pod ga��zi�!');
end;

procedure TfrmEditWindow.aRemoveItemExecute(Sender: TObject);

begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

DoRemoveItem;
end;

procedure TfrmEditWindow.aRemovePaneExecute(Sender: TObject);

begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

DoRemovePane;
end;

procedure TfrmEditWindow.aRemoveTabExecute(Sender: TObject);

begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

DoRemoveTab;
end;

procedure TfrmEditWindow.CheckActionsAvailability;

var Node : TTreeNode;
    Obj : TObject;
    Tab : TSpkTab;
    Pane : TSpkPane;
    index : integer;
    Item: TSpkBaseItem;

begin
if (FToolbar=nil) or (FDesigner=nil) then
   begin
   // Brak toolbara lub designera

   aAddTab.Enabled:=false;
   aRemoveTab.Enabled:=false;
   aAddPane.Enabled:=false;
   aRemovePane.Enabled:=false;
   aAddLargeButton.Enabled:=false;
   aAddSmallButton.Enabled:=false;
   aAddCheckbox.Enabled := false;
   aAddRadioButton.Enabled := false;
   aRemoveItem.Enabled:=false;
   aMoveUp.Enabled:=false;
   aMoveDown.Enabled:=false;
   end
else
   begin
   Node:=tvStructure.Selected;

   if Node = nil then
      begin
      // Pusty toolbar
      aAddTab.Enabled:=true;
      aRemoveTab.Enabled:=false;
      aAddPane.Enabled:=false;
      aRemovePane.Enabled:=false;
      aAddLargeButton.Enabled:=false;
      aAddSmallButton.Enabled:=false;
      aAddCheckbox.Enabled := false;
      aAddRadioButton.Enabled := false;
      aRemoveItem.Enabled:=false;
      aMoveUp.Enabled:=false;
      aMoveDown.Enabled:=false;
      end
   else
      begin
      Obj:=TObject(Node.Data);
      if Obj=nil then
         raise exception.create('TfrmEditWindow.CheckActionsAvailability: Nieprawid�owe dane w ga��zi!');

      if Obj is TSpkTab then
         begin
         Tab:=Obj as TSpkTab;

         if not(CheckValidTabNode(Node)) then
            raise exception.create('TfrmEditWindow.CheckActionsAvailability: Uszkodzona struktura drzewa!');

         aAddTab.Enabled:=true;
         aRemoveTab.Enabled:=true;
         aAddPane.Enabled:=true;
         aRemovePane.Enabled:=false;
         aAddLargeButton.Enabled:=false;
         aAddSmallButton.Enabled:=false;
         aAddCheckbox.Enabled := false;
         aAddRadioButton.Enabled := false;
         aRemoveItem.Enabled:=false;

         index:=FToolbar.Tabs.IndexOf(Tab);
         if index=-1 then
            raise exception.create('TfrmEditWindow.CheckActionsAvailability: Uszkodzona struktura drzewa!');

         aMoveUp.enabled:=(index>0);
         aMoveDown.enabled:=(index<FToolbar.Tabs.Count-1);
         end else
      if Obj is TSpkPane then
         begin
         Pane:=TSpkPane(Obj);

         if not(CheckValidPaneNode(Node)) then
            raise exception.create('TfrmEditWindow.CheckActionsAvailability: Uszkodzona struktura drzewa!');

         Tab:=TSpkTab(Node.Parent.Data);

         aAddTab.Enabled:=true;
         aRemoveTab.enabled:=false;
         aAddPane.Enabled:=true;
         aRemovePane.Enabled:=true;
         aAddLargeButton.Enabled:=true;
         aAddSmallButton.Enabled:=true;
         aAddCheckbox.Enabled := true;
         aAddRadiobutton.Enabled := true;
         aRemoveItem.Enabled:=false;

         index:=Tab.Panes.IndexOf(Pane);

         if index=-1 then
            raise exception.create('TfrmEditWindow.CheckActionsAvailability: Uszkodzona struktura drzewa!');

         aMoveUp.Enabled:=(index>0);
         aMoveDown.Enabled:=(index<Tab.Panes.Count-1);
         end else
      if Obj is TSpkBaseItem then
         begin
         Item:=TSpkBaseItem(Obj);

         if not(CheckValidItemNode(Node)) then
            raise exception.create('TfrmEditWindow.CheckActionsAvailability: Uszkodzona struktura drzewa!');

         Pane:=TSpkPane(Node.Parent.Data);

         aAddTab.Enabled:=true;
         aRemoveTab.Enabled:=false;
         aAddPane.Enabled:=true;
         aRemovePane.Enabled:=false;
         aAddLargeButton.Enabled:=true;
         aAddSmallButton.Enabled:=true;
         aAddCheckbox.Enabled := true;
         aAddRadioButton.Enabled := true;
         aRemoveItem.Enabled:=true;

         index:=Pane.Items.IndexOf(Item);

         if index=-1 then
            raise exception.create('TfrmEditWindow.CheckActionsAvailability: Uszkodzona struktura drzewa!');

         aMoveUp.Enabled:=(index>0);
         aMoveDown.Enabled:=(index<Pane.Items.Count-1);
         end else
             raise exception.create('TfrmEditWindow.CheckActionsAvailability: Nieprawid�owy obiekt podwieszony pod ga��zi�!');
      end;
   end;

end;

function TfrmEditWindow.CheckValidItemNode(Node: TTreeNode): boolean;
begin
result:=false;
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

{$B-}
result:=(Node<>nil) and
        (Node.Data<>nil) and
        (TObject(Node.Data) is TSpkBaseItem) and
        CheckValidPaneNode(Node.Parent);
end;

function TfrmEditWindow.CheckValidPaneNode(Node: TTreeNode): boolean;
begin
result:=false;
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

{$B-}
result:=(Node<>nil) and
        (Node.Data<>nil) and
        (TObject(Node.Data) is TSpkPane) and
        CheckValidTabNode(Node.Parent);
end;

function TfrmEditWindow.CheckValidTabNode(Node: TTreeNode): boolean;
begin
result:=false;
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

{$B-}
result:=(Node<>nil) and
        (Node.Data<>nil) and
        (TObject(Node.Data) is TSpkTab);
end;

procedure TfrmEditWindow.FormActivate(Sender: TObject);
begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

if not(ValidateTreeData) then
   BuildTreeData;
end;

procedure TfrmEditWindow.FormDestroy(Sender: TObject);
begin
if FToolbar<>nil then
   FToolbar.RemoveFreeNotification(self);
end;

procedure TfrmEditWindow.FormShow(Sender: TObject);
begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

BuildTreeData;
end;

function TfrmEditWindow.GetItemCaption(Item: TSpkBaseItem): string;
begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

if Item is TSpkBaseButton then
   begin
   result:=TSpkBaseButton(Item).Caption;
   end else
       result:='<Unknown caption>';
end;

procedure TfrmEditWindow.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if (AComponent = FToolbar) and (Operation = opRemove) then
     begin
     // W�a�nie zwalniany jest toolbar, kt�rego zawarto�� wy�wietla okno
     // edytora. Trzeba posprz�ta� zawarto�� - w przeciwnym wypadku okno
     // b�dzie mia�o referencje do ju� usuni�tych element�w toolbara, co
     // sko�czy si� AVami...

     SetData(nil, nil);
     end;
end;

procedure TfrmEditWindow.SetItemCaption(Item: TSpkBaseItem; const Value : string);
begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

if Item is TSpkBaseButton then
   TSpkBaseButton(Item).Caption:=Value;
end;

procedure TfrmEditWindow.SetData(AToolbar: TSpkToolbar; ADesigner: TComponentEditorDesigner);

begin
if FToolbar<>nil then
   FToolbar.RemoveFreeNotification(self);

FToolbar:=AToolbar;
FDesigner:=ADesigner;

if FToolbar<>nil then
   FToolbar.FreeNotification(self);

BuildTreeData;
end;

procedure TfrmEditWindow.DoRemoveItem;
var
  Item: TSpkBaseItem;
  index: Integer;
  Node: TTreeNode;
  Pane: TSpkPane;
  NextNode: TTreeNode;
begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

  Node := tvStructure.Selected;
  if not (CheckValidItemNode(Node)) then
    raise Exception.Create('TfrmEditWindow.aRemoveItemExecute: Uszkodzona struktura drzewa!');
  Item := TSpkBaseItem(Node.Data);
  Pane := TSpkPane(Node.Parent.Data);
  index := Pane.Items.IndexOf(Item);
  if index = -1 then
    raise exception.create('TfrmEditWindow.aRemoveItemExecute: Uszkodzona struktura drzewa!');
  if Node.getPrevSibling <> nil then
    NextNode := Node.getPrevSibling
  else if Node.GetNextSibling <> nil then
    NextNode := Node.getNextSibling
  else
    NextNode := Node.Parent;
  Pane.Items.Delete(index);
  tvStructure.Items.delete(node);
  NextNode.Selected := true;
  CheckActionsAvailability;
end;

procedure TfrmEditWindow.DoRemovePane;
var
  Pane: TSpkPane;
  NextNode: TTreeNode;
  index: Integer;
  Node: TTreeNode;
  Tab: TSpkTab;
begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

  Node := tvStructure.Selected;
  if not (CheckValidPaneNode(Node)) then
    raise exception.create('TfrmEditWindow.aRemovePaneExecute: Uszkodzona struktura drzewa!');
  Pane := TSpkPane(Node.Data);
  Tab := TSpkTab(Node.Parent.Data);
  index := Tab.Panes.IndexOf(Pane);
  if index = -1 then
    raise Exception.create('TfrmEditWindow.aRemovePaneExecute: Uszkodzona struktura drzewa!');
  if Node.GetPrevSibling <> nil then
    NextNode := Node.GetPrevSibling
  else if Node.GetNextSibling <> nil then
    NextNode := Node.GetNextSibling
  else
    NextNode := Node.Parent;
  Tab.Panes.Delete(index);
  tvStructure.Items.Delete(Node);
  NextNode.Selected := true;
  CheckActionsAvailability;
end;

procedure TfrmEditWindow.DoRemoveTab;
var
  Node: TTreeNode;
  Tab: TSpkTab;
  index: Integer;
  NextNode: TTreeNode;
  //DesignObj: IDesignObject;
begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

  Node := tvStructure.Selected;
  if not (CheckValidTabNode(Node)) then
    raise exception.create('TfrmEditWindow.aRemoveTabExecute: Uszkodzona struktura drzewa!');
  Tab := TSpkTab(Node.Data);
  index := FToolbar.Tabs.IndexOf(Tab);
  if index = -1 then
    raise exception.create('TfrmEditWindow.aRemoveTabExecute: Uszkodzona struktura drzewa!');
  if Node.GetPrevSibling <> nil then
    NextNode := Node.GetPrevSibling
  else if Node.GetNextSibling <> nil then
    NextNode := Node.GetNextSibling
  else
    NextNode := nil;
  FToolbar.Tabs.Delete(index);
  tvStructure.Items.Delete(Node);
  if assigned(NextNode) then
  begin
    // Zdarzenie OnChange wyzwoli aktualizacj� zaznaczonego obiektu w
    // Object Inspectorze
    NextNode.Selected := true;
    CheckActionsAvailability;
  end
  else
  begin
    // Nie ma ju� �adnych obiekt�w na li�cie, ale co� musi zosta� wy�wietlone w
    // Object Inspectorze - wy�wietlamy wi�c samego toolbara (w przeciwnym
    // wypadku IDE b�dzie pr�bowa�o wy�wietli� w Object Inspectorze w�a�ciwo�ci
    // w�a�nie zwolnionego obiektu, co sko�czy si�, powiedzmy, niezbyt mi�o)
    //DesignObj := PersistentToDesignObject(FToolbar);
    FDesigner.SelectOnlyThisComponent(FToolbar);
    CheckActionsAvailability;
  end;
end;

procedure TfrmEditWindow.BuildTreeData;
var
  i: Integer;
  panenode: TTreeNode;
  j: Integer;
  tabnode: TTreeNode;
  k : Integer;
  itemnode: TTreeNode;
  Obj: TSpkBaseItem;
  s: string;
  node: TTreeNode;
begin
  Caption:='Editing TSpkToolbar contents';

  // Clear tree, but don't remove existing toolbar children from the form
  tvStructure.OnDeletion := nil;
  tvStructure.Items.Clear;
  tvStructure.OnDeletion := tvStructureDeletion;

  if (FToolbar<>nil) and (FDesigner<>nil) then
     begin
     if FToolbar.Tabs.Count > 0 then
       for i := 0 to FToolbar.Tabs.Count - 1 do
       begin
         tabnode := tvStructure.Items.AddChild(nil, FToolbar.Tabs[i].Caption);
         tabnode.ImageIndex := 0;
         tabnode.SelectedIndex := 0;
         tabnode.Data := FToolbar.Tabs[i];
         if FToolbar.Tabs[i].Panes.Count > 0 then
           for j := 0 to FToolbar.Tabs.Items[i].Panes.Count - 1 do
           begin
             panenode := tvStructure.Items.AddChild(tabnode, FToolbar.Tabs[i].Panes[j].Caption);
             panenode.ImageIndex := 1;
             panenode.SelectedIndex := 1;
             panenode.Data := FToolbar.Tabs[i].Panes[j];
             if FToolbar.Tabs[i].Panes[j].Items.Count > 0 then
                for k := 0 to FToolbar.Tabs[i].Panes[j].Items.Count - 1 do
                begin
                Obj:=FToolbar.Tabs[i].Panes[j].Items[k];
                s:=GetItemCaption(Obj);

                itemnode:=tvStructure.Items.AddChild(panenode,s);
                itemnode.Imageindex:=2;
                itemnode.Selectedindex:=2;
                itemnode.Data:=Obj;
                end;
           end;
       end;
     end;

  if (tvStructure.Items.Count > 0) and (FToolbar.TabIndex > -1) then begin
    node := tvStructure.Items[0];
    while (node <> nil) do begin
      if TSpkTab(node.Data) = FToolbar.Tabs[FToolbar.TabIndex] then break;
      node := node.GetNextSibling;
    end;
    if (node <> nil) then begin
      node.Selected := true;
      node.Expand(true);
    end;
  end;

  CheckActionsAvailability;
end;

procedure TfrmEditWindow.RefreshNames;

var tabnode, panenode, itemnode : TTreeNode;
    Obj: TSpkBaseItem;
    s: string;

begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

tabnode:=tvStructure.Items.GetFirstNode;
while tabnode<>nil do
      begin
      if not(CheckValidTabNode(tabnode)) then
         raise exception.create('TfrmEditWindow.RefreshNames: Uszkodzona struktura drzewa!');

      tabnode.Text:=TSpkTab(tabnode.Data).Caption;

      panenode:=tabnode.getFirstChild;
      while panenode<>nil do
            begin
            if not(CheckValidPaneNode(panenode)) then
               raise exception.create('TfrmEditWindow.RefreshNames: Uszkodzona struktura drzewa!');

            panenode.Text:=TSpkPane(panenode.Data).Caption;

            itemnode:=panenode.getFirstChild;
            while itemnode<>nil do
                  begin
                  if not(CheckValidItemNode(itemnode)) then
                     raise exception.create('TfrmEditWindow.RefreshNames: Uszkodzona struktura drzewa!');

                  Obj:=TSpkBaseItem(itemnode.Data);
                  s:=GetItemCaption(Obj);

                  itemnode.Text:=s;

                  itemnode:=itemnode.getNextSibling;
                  end;

            panenode:=panenode.getNextSibling;
            end;

      tabnode:=tabnode.getNextSibling;
      end;
end;

procedure TfrmEditWindow.tvStructureChange(Sender: TObject; Node: TTreeNode);

var Obj : TObject;
    Tab : TSpkTab;
    Pane : TSpkPane;
    Item : TSpkBaseItem;
    //DesignObj : IDesignObject;
    index : integer;

begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

if assigned(Node) then
   begin
   Obj:=TObject(Node.Data);

   if Obj=nil then
      raise exception.create('TfrmEditWindow.tvStructureChange: Nieprawid�owe dane w ga��zi!');

   if Obj is TSpkTab then
      begin
      Tab:=TSpkTab(Obj);
      FDesigner.SelectOnlyThisComponent(Tab);
      index:=FToolbar.Tabs.IndexOf(Tab);
      if index=-1 then
         raise exception.create('TfrmEditWindow.tvStructureChange: Uszkodzona struktura drzewa!');
      FToolbar.TabIndex:=index;
      end else
   if Obj is TSpkPane then
      begin
      Pane:=TSpkPane(Obj);
      FDesigner.SelectOnlyThisComponent(Pane);

      if not(CheckValidPaneNode(Node)) then
         raise exception.create('TfrmEditWindow.tvStructureChange: Uszkodzona struktura drzewa!');

      Tab:=TSpkTab(Node.Parent.Data);

      index:=FToolbar.Tabs.IndexOf(Tab);
      if index=-1 then
         raise exception.create('TfrmEditWindow.tvStructureChange: Uszkodzona struktura drzewa!');
      FToolbar.TabIndex:=index;
      end else
   if Obj is TSpkBaseItem then
      begin
      Item:=TSpkBaseItem(Obj);
      FDesigner.SelectOnlyThisComponent(Item);

      if not(CheckValidItemNode(Node)) then
         raise exception.create('TfrmEditWindow.tvStructureChange: Uszkodzona struktura drzewa!');

      Tab:=TSpkTab(Node.Parent.Parent.Data);

      index:=FToolbar.Tabs.IndexOf(Tab);
      if index=-1 then
         raise exception.create('TfrmEditWindow.tvStructureChange: Uszkodzona struktura drzewa!');
      FToolbar.TabIndex:=index;
      end else
          raise exception.create('TfrmEditWindow.tvStructureChange: Nieprawid�owy obiekt podwieszony pod ga��zi�!');
   end else
       begin
       FDesigner.SelectOnlyThisComponent(FToolbar);
       end;

CheckActionsAvailability;
end;

procedure TfrmEditWindow.tvStructureDeletion(Sender:TObject; Node:TTreeNode);
var
  RunNode: TTreeNode;
  index: Integer;
  comp: TSpkComponent;
begin
  if Node = nil then
    exit;
  // Recursively delete children and destroy their data
  RunNode := Node.GetFirstChild;
  while RunNode <> nil do begin
    RunNode.Delete;
    RunNode := RunNode.GetNextSibling;
  end;
  // Destroy node's data
  TSpkComponent(Node.Data).Free;
end;

procedure TfrmEditWindow.tvStructureEdited(Sender: TObject; Node: TTreeNode;
  var S: string);
var
  Tab: TSpkTab;
  Pane: TSpkPane;
  Item: TSpkBaseItem;

begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

if Node.Data = nil then
   raise exception.create('TfrmEditWindow.tvStructureEdited: Uszkodzona struktura drzewa!');

if TObject(Node.Data) is TSpkTab then
   begin
   Tab:=TSpkTab(Node.Data);
   Tab.Caption:=S;

   FDesigner.Modified;
   end else
if TObject(Node.Data) is TSpkPane then
   begin
   Pane:=TSpkPane(Node.Data);
   Pane.Caption:=S;

   FDesigner.Modified;
   end else
if TObject(Node.Data) is TSpkBaseItem then
   begin
   Item:=TSpkBaseItem(Node.Data);
   SetItemCaption(Item, S);

   FDesigner.Modified;
   end else
       raise exception.create('TfrmEditWindow.tvStructureEdited: Uszkodzona struktura drzewa!');
end;

procedure TfrmEditWindow.tvStructureKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

if Key = VK_DELETE then
   begin
   if tvStructure.Selected<>nil then
      begin
      // Sprawdzamy, jakiego rodzaju obiekt jest zaznaczony - wystarczy
      // przetestowa� typ podwieszonego obiektu.
      if TObject(tvStructure.Selected.Data) is TSpkTab then
         begin
         DoRemoveTab;
         end else
      if TObject(tvStructure.Selected.Data) is TSpkPane then
         begin
         DoRemovePane;
         end else
      if TObject(tvStructure.Selected.Data) is TSpkBaseItem then
         begin
         DoRemoveItem;
         end else
             raise exception.create('TfrmEditWindow.tvStructureKeyDown: Uszkodzona struktura drzewa!');
      end;
   end;
end;

function TfrmEditWindow.ValidateTreeData: boolean;

var
  i: Integer;
  TabsValid: Boolean;
  TabNode: TTreeNode;
  j: Integer;
  PanesValid: Boolean;
  PaneNode: TTreeNode;
  k: Integer;
  ItemsValid: Boolean;
  ItemNode: TTreeNode;

begin
result:=false;
if (FToolbar=nil) or (FDesigner=nil) then
   exit;

i:=0;
TabsValid:=true;
TabNode:=tvStructure.Items.GetFirstNode;

while (i<FToolbar.Tabs.Count) and TabsValid do
      begin
      TabsValid:=TabsValid and (TabNode<>nil);

      if TabsValid then
         TabsValid:=TabsValid and (TabNode.Data = FToolbar.Tabs[i]);

      if TabsValid then
         begin
         j:=0;
         PanesValid:=true;
         PaneNode:=TabNode.GetFirstChild;

         while (j<FToolbar.Tabs[i].Panes.Count) and PanesValid do
               begin
               PanesValid:=PanesValid and (PaneNode<>nil);

               if PanesValid then
                  PanesValid:=PanesValid and (PaneNode.Data = FToolbar.Tabs[i].Panes[j]);

               if PanesValid then
                  begin
                  k:=0;
                  ItemsValid:=true;
                  ItemNode:=PaneNode.GetFirstChild;

                  while (k<FToolbar.Tabs[i].Panes[j].Items.Count) and ItemsValid do
                        begin
                        ItemsValid:=ItemsValid and (ItemNode<>nil);

                        if ItemsValid then
                           ItemsValid:=ItemsValid and (ItemNode.Data = FToolbar.Tabs[i].Panes[j].Items[k]);

                        if ItemsValid then
                           begin
                           inc(k);
                           ItemNode:=ItemNode.GetNextSibling;
                           end;
                        end;

                  // Wa�ne! Trzeba sprawdzi�, czy w drzewie nie ma dodatkowych
                  // element�w!
                  ItemsValid:=ItemsValid and (ItemNode = nil);

                  PanesValid:=PanesValid and ItemsValid;
                  end;

               if PanesValid then
                  begin
                  inc(j);
                  PaneNode:=PaneNode.GetNextSibling;
                  end;
               end;

         // Wa�ne! Trzeba sprawdzi�, czy w drzewie nie ma dodatkowych
         // element�w!
         PanesValid:=PanesValid and (PaneNode = nil);

         TabsValid:=TabsValid and PanesValid;
         end;

      if TabsValid then
         begin
         inc(i);
         TabNode:=TabNode.GetNextSibling;
         end;
      end;

// Wa�ne! Trzeba sprawdzi�, czy w drzewie nie ma dodatkowych
// element�w!
TabsValid:=TabsValid and (TabNode = nil);

result:=TabsValid;
end;

end.
