import { LightningElement, track, wire } from "lwc";
import getObjects from "@salesforce/apex/ViewObjectPermissionController.getObjects";
import getFields from "@salesforce/apex/ViewObjectPermissionController.getFields";
import getObjectAccess from "@salesforce/apex/ViewObjectPermissionController.getObjectAccess";
import getFieldsAccess from "@salesforce/apex/ViewObjectPermissionController.getFieldsAccess";
import getOrgUsers from "@salesforce/apex/ViewObjectPermissionController.getOrgUsers";

// The columns for the data table
const columns = [
  { label: "FieldName", fieldName: "FieldName", type: "text", sortable: true },
  {
    label: "IsAccessible",
    fieldName: "IsAccessible",
    type: "boolean",
    sortable: true
  },
  {
    label: "IsUpdatable",
    fieldName: "IsUpdatable",
    type: "boolean",
    sortable: true
  },
  {
    label: "IsCreatable",
    fieldName: "IsCreatable",
    type: "boolean",
    sortable: true
  }
];

export default class ViewObjectPermissions extends LightningElement {
  objects = []; // Array to store retrieved Salesforce objects
  fields = []; // Array to store retrieved fields of a selected object
  users = []; // Array to store retrieved organization users
  field; // Selected field
  objName; // Selected Salesforce object name
  user; // Selected organization user
  data; // The data for the data table
  columns = columns; // The columns for the data table

  // Function to retrieve a list of organization users
  connectedCallback() {
    getOrgUsers().then((result) => {
      this.users = result.map((user) => ({ label: user.Name, value: user.Id }));
    });
  }

  // Function to retrieve a list of Salesforce objects and populates 'objects' array
  @wire(getObjects)
  wiredObjects({ error, data }) {
    if (data) {
      this.objects = data.map((object) => ({ label: object, value: object }));
    } else if (error) {
      console.error(error);
    }
  }

  // Function to handle changes in the selected Salesforce object and populates 'fields' array
  // @param {event} event - Event sent when the selected Salesforce object is changed
  handleObjectChange(event) {
    const selectedOption = event.detail.value;
    this.objName = selectedOption;
    this.field = null;
    if (selectedOption) {
      getFields({ objectName: selectedOption }).then((result) => {
        this.fields = [
          { label: "---Select Field---", value: "" },
          ...result.map((field) => ({ label: field.Label, value: field.Name }))
        ];
      });
    } else {
      this.fields = [{ label: "---Select Field---", value: "" }];
      this.data = null;
    }
  }

  // Function to handle changes in the selected field
  handleFieldChange(event) {
    const selectedOption = event.detail.value;
    this.field = selectedOption;
  }

  // Function to handle changes in the selected organization user
  handleUserChange(event) {
    const selectedOption = event.detail.value;
    this.user = selectedOption;
  }

  // Function to retrieve object/field access for the selected Salesforce object or field and user
  handleClick() {
    if (!this.objName || !this.user) return;

    if (this.field) {
      getFieldsAccess({
        objectName: this.objName,
        fieldName: this.field,
        userId: this.user
      })
        .then((result) => {
          this.data = result;
        })
        .catch((error) => {
          console.error(error);
        });
    } else {
      getObjectAccess({ objectName: this.objName, userId: this.user })
        .then((result) => {
          this.data = result;
        })
        .catch((error) => {
          console.error(error);
        });
    }
  }
}
