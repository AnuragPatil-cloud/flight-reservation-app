import React from "react";

const Contact = () => {
  const handleSubmit = (e) => {
    e.preventDefault();
    alert("Email sent");
  };

  return (
    <div className="contact">
      <div className="row">
        <div className="col-md-5">
          <h2>Contact Us</h2>
          <br />

          <p>
            <i className="bx bxs-map"></i>
            {"  Katraj, Near Katraj Talawa, Katraj"}
          </p>

          <p>
            <i className="bx bxs-phone"></i>
            {"  9226531573"}
          </p>

          <p>
            <i className="bx bxs-envelope"></i>
            {"  anurag.patil.devops@gmail.com"}
          </p>
        </div>

        <div className="col-md-6">
          <h2>Stay In Touch</h2>
          <br />

          <form onSubmit={handleSubmit}>
            <input
              type="email"
              className="form-control"
              placeholder="Enter your email address"
              required
            />

            <br />

            <button type="submit" className="btn btn-primary">
              Subscribe
            </button>
          </form>

          <p>
            Enter your email address for promotions, news and updates.
          </p>
        </div>
      </div>
    </div>
  );
};

export default Contact;
