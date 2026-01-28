import React, { useContext } from "react";
import Login from "./pages/Login";
import { ToastContainer } from "react-toastify";
import { AdminContext } from "./context/AdminContext";
import Navbar from "./components/Navbar";
import Sidebar from "./components/Sidebar";
import { Navigate, Route, Routes } from "react-router-dom";
import Dashboard from "./pages/Admin/Dashboard";
import { ExpertContext } from "./context/ExpertContext";
import ExpertsList from "./pages/Admin/ExpertsList";
import AddExpert from "./pages/Admin/AddExpert";
import ExpertProfile from "./pages/Expert/ExpertProfile";
import ExpertBookings from "./pages/Expert/ExpertBookings";

const App = () => {
  const { aToken } = useContext(AdminContext);
  const { eToken } = useContext(ExpertContext);
  return aToken || eToken ? (
    <div className="min-h-screen">
      <ToastContainer />
      <Navbar />
      <div className="flex items-start">
        <Sidebar />
        <Routes>
          {/* Admin Route */}
          <Route
            path="/"
            element={
              <Navigate
                to={aToken ? "/admin-dashboard" : "/expert-profile"}
                replace
              />
            }
          />
          <Route path="/admin-dashboard" element={<Dashboard />} />
          <Route path="/experts" element={<ExpertsList />} />
          <Route path="/experts/add" element={<AddExpert />} />

          {/* Expert Route */}
          <Route path="/expert-profile" element={<ExpertProfile />} />
          <Route path="/expert-bookings" element={<ExpertBookings />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </div>
    </div>
  ) : (
    <>
      <Login />
      <ToastContainer />
    </>
  );
};

export default App;
