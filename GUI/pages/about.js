import * as React from "react";
import Container from "@mui/material/Container";
import Typography from "@mui/material/Typography";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Link from "../components/navigation/Link";
import Copyright from "../components/Copyright";

export default function About() {
  return (
    <Container maxWidth="sm">
      <Box sx={{ my: 4 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          Follow work in progress on the repo:
          <Button
            variant="contained"
            component={Link}
            noLinkStyle
            href="https://github.com/Briojas/BeOurPest"
          >
            Github Repo
          </Button>
        </Typography>
      </Box>
    </Container>
  );
}
