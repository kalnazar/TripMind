import { createContext, useState } from "react";
import axios from "axios";
import { toast } from "react-toastify";

export const AdminContext = createContext();

const AdminContextProvider = (props) => {
  const [aToken, setAToken] = useState(
    localStorage.getItem("aToken") ? localStorage.getItem("aToken") : ""
  );
  const [experts, setExperts] = useState([]);
  const [users, setUsers] = useState([]);
  const [dashData, setDashData] = useState(null);

  const backendUrl = import.meta.env.VITE_BACKEND_URL;

  const authHeaders = () => ({
    Authorization: `Bearer ${aToken}`,
  });

  const getDashboard = async () => {
    try {
      const { data } = await axios.get(backendUrl + "/api/admin/dashboard", {
        headers: authHeaders(),
      });
      setDashData(data);
    } catch (error) {
      toast.error(error?.response?.data?.message || error.message);
    }
  };

  const listExperts = async () => {
    try {
      const { data } = await axios.get(backendUrl + "/api/admin/experts", {
        headers: authHeaders(),
      });
      setExperts(data);
    } catch (error) {
      toast.error(error?.response?.data?.message || error.message);
    }
  };

  const listUsers = async () => {
    try {
      const { data } = await axios.get(backendUrl + "/api/admin/users", {
        headers: authHeaders(),
      });
      setUsers(data);
    } catch (error) {
      toast.error(error?.response?.data?.message || error.message);
    }
  };

  const updateExpert = async (id, payload) => {
    try {
      const { data } = await axios.patch(
        backendUrl + `/api/admin/experts/${id}`,
        payload,
        { headers: authHeaders() }
      );
      setExperts((prev) =>
        prev.map((expert) => (expert.id === id ? data : expert))
      );
      toast.success("Expert updated");
      return data;
    } catch (error) {
      toast.error(error?.response?.data?.message || error.message);
      throw error;
    }
  };

  const createExpert = async (payload) => {
    try {
      const { data } = await axios.post(backendUrl + "/api/admin/experts", payload, {
        headers: authHeaders(),
      });
      toast.success("Expert created");
      if (data) {
        setExperts((prev) => [data, ...prev]);
      }
      return data;
    } catch (error) {
      toast.error(error?.response?.data?.message || error.message);
      throw error;
    }
  };

  const deleteExpert = async (id) => {
    try {
      await axios.delete(backendUrl + `/api/admin/experts/${id}`, {
        headers: authHeaders(),
      });
      setExperts((prev) => prev.filter((expert) => expert.id !== id));
      toast.success("Expert deleted");
    } catch (error) {
      toast.error(error?.response?.data?.message || error.message);
      throw error;
    }
  };

  const value = {
    aToken,
    setAToken,
    backendUrl,
    dashData,
    getDashboard,
    experts,
    listExperts,
    users,
    listUsers,
    updateExpert,
    createExpert,
    deleteExpert,
  };

  return (
    <AdminContext.Provider value={value}>
      {props.children}
    </AdminContext.Provider>
  );
};

export default AdminContextProvider;
